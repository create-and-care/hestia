module VisualCheck
  # Turns the Puppeteer driver's raw results.json plus the Ruby side's own
  # preflight route skips into the two files a human actually reads:
  # tmp/visual/report.md (violations, worst screens first) and
  # tmp/visual/routes.txt (what got covered vs. skipped, and why).
  class ReportBuilder
    RULE_LABELS = {
      "touch_target" => "Cible tactile < 36px",
      "overflow_page" => "Débordement horizontal (page)",
      "overflow_container" => "Débordement horizontal (conteneur)",
      "contrast" => "Contraste de texte insuffisant",
      "spacing_scale" => "Espacement hors échelle (multiple de 4px)",
      "font_weight" => "Graisse hors système (> 600)",
      "font_size" => "Taille hors système (< 13px)"
    }.freeze

    def initialize(out_dir:, results:, route_skips:, covered_routes:)
      @out_dir = out_dir
      @results = results
      @route_skips = route_skips
      @covered_routes = covered_routes
    end

    def call
      File.write(@out_dir.join("routes.txt"), routes_txt)
      File.write(@out_dir.join("report.md"), report_md)
    end

    private
      def violations = @results["violations"] || []
      def token_violations = @results["tokenViolations"] || []
      def runtime_skips = @results["runtimeSkips"] || []
      def spacing_histograms = @results["spacingHistograms"] || {}
      def warnings = @results["warnings"] || []

      # ---- routes.txt -------------------------------------------------

      def routes_txt
        runtime_skip_index = runtime_skips.index_by { |s| [ s["pass"], s["route"] ] }
        lines = [ "# visual:check route coverage", "" ]

        %w[public seeded empty].each do |pass|
          covered = @covered_routes.select { |r| r[:pass] == pass }
          preflight_skipped = @route_skips.select { |r| r[:pass] == pass }

          runtime_skipped, actually_covered = covered.partition { |r| runtime_skip_index[[ pass, r[:name] ]] }

          lines << "## #{pass} (#{actually_covered.size} covered, #{preflight_skipped.size + runtime_skipped.size} skipped)"
          actually_covered.sort_by { |r| r[:name].to_s }.each do |r|
            lines << format("COVERED  %-45s GET %s", "#{r[:controller]}##{r[:action]}", r[:url])
          end
          runtime_skipped.sort_by { |r| r[:name].to_s }.each do |r|
            reason = runtime_skip_index[[ pass, r[:name] ]]["reason"]
            lines << format("SKIPPED  %-45s %s", "#{r[:controller]}##{r[:action]}", "— #{reason}")
          end
          preflight_skipped.sort_by { |r| r[:name].to_s }.each do |r|
            lines << format("SKIPPED  %-45s %s", "#{r[:controller]}##{r[:action]}", "— #{r[:reason]}")
          end
          lines << ""
        end

        lines.join("\n")
      end

      # ---- report.md ----------------------------------------------------

      def report_md
        screens = group_by_screen

        [
          "# Visual check report",
          "",
          warnings_section,
          top_screens_section(screens),
          "## Détail par écran",
          "",
          *screens.flat_map { |key, data| screen_section(key, data) },
          "## Résumé par règle",
          "",
          rule_summary_table,
          "",
          "## Récurrences inter-écrans",
          "",
          "_Un même élément de chrome (sidebar, header) partagé par tout l'appli produit un finding par écran où il apparaît — ce qui gonfle le compte de \"findings distincts\" ci-dessus sans que ce soit N bugs différents. Cette table regroupe par cause probable (même règle, même signature d'élément), tous écrans confondus, pour distinguer un vrai problème sitewide d'un bruit de comptage._",
          "",
          cross_screen_rollup_table,
          "",
          "## Design tokens — états adjacents (ΔE76)",
          "",
          token_section,
          "## Échelle d'espacement — valeurs distinctes par écran",
          "",
          spacing_rhythm_section
        ].compact.join("\n")
      end

      def group_by_screen
        grouped = violations.group_by { |v| [ v["pass"], v["route"], v["viewport"], v["theme"] ] }
        grouped.sort_by { |_, vs| -vs.sum { |v| v["count"] || 1 } }.to_h
      end

      def warnings_section
        return nil if warnings.empty?

        ([ "## ⚠️ Avertissement", "" ] + warnings.map { |w| "- #{w}" } + [ "" ]).join("\n")
      end

      def top_screens_section(screens)
        top = screens.first(10)
        return "## Top 10 écrans (aucune violation trouvée)\n\n" if top.empty?

        lines = [ "## Top 10 écrans par nombre de violations", "", "| Écran | Occurrences | Findings distincts |", "| --- | --- | --- |" ]
        top.each do |key, vs|
          lines << "| #{screen_label(key)} | #{vs.sum { |v| v['count'] || 1 }} | #{vs.size} |"
        end
        lines << ""
        lines.join("\n")
      end

      def screen_section(key, vs)
        lines = [ "### #{screen_label(key)}", "" ]
        vs.sort_by { |v| v["rule"].to_s }.each do |v|
          count_suffix = (v["count"] || 1) > 1 ? " (×#{v['count']})" : ""
          lines << "- **#{RULE_LABELS.fetch(v['rule'], v['rule'])}**#{count_suffix} — `#{v['selector']}` — #{v['value']}"
        end
        lines << ""
        lines
      end

      def screen_label(key)
        pass, route, viewport, theme = key
        "`#{pass}` #{route} @ #{viewport}px / #{theme}"
      end

      def cross_screen_rollup_table
        by_cause = violations.group_by { |v| [ v["rule"], v["signature"] || v["selector"] ] }
        return "_Aucune violation détectée._" if by_cause.empty?

        rows = by_cause.map do |(rule, signature), vs|
          screens = vs.map { |v| [ v["pass"], v["route"], v["viewport"], v["theme"] ] }.uniq
          {
            rule: rule, signature: signature, screen_count: screens.size,
            occurrences: vs.sum { |v| v["count"] || 1 }, example: vs.first["value"]
          }
        end.sort_by { |r| -r[:screen_count] }

        lines = [ "| Règle | Élément | Écrans touchés | Occurrences totales | Exemple |", "| --- | --- | --- | --- | --- |" ]
        rows.first(40).each do |r|
          lines << "| #{RULE_LABELS.fetch(r[:rule], r[:rule])} | `#{r[:signature]}` | #{r[:screen_count]} | #{r[:occurrences]} | #{r[:example]} |"
        end
        lines << "" << "_(#{rows.size - 40} cause(s) supplémentaire(s) non listée(s) — triées par nombre d'écrans touchés)_" if rows.size > 40
        lines.join("\n")
      end

      def rule_summary_table
        counts = Hash.new(0)
        occurrences = Hash.new(0)
        violations.each do |v|
          counts[v["rule"]] += 1
          occurrences[v["rule"]] += v["count"] || 1
        end
        return "_Aucune violation détectée._" if counts.empty?

        lines = [ "| Règle | Findings distincts | Occurrences totales |", "| --- | --- | --- |" ]
        counts.sort_by { |_, c| -c }.each do |rule, count|
          lines << "| #{RULE_LABELS.fetch(rule, rule)} | #{count} | #{occurrences[rule]} |"
        end
        lines.join("\n")
      end

      def token_section
        return "_Non mesuré._\n\n" if token_violations.empty?

        failing = token_violations.reject { |t| t["passed"] }
        lines = []
        if failing.empty?
          lines << "Toutes les paires de tokens testées restent distinctes (ΔE76 >= 4) dans les deux thèmes."
        else
          lines.push("| Thème | Paire | ΔE76 | Valeurs |", "| --- | --- | --- | --- |")
          failing.each do |t|
            lines << "| #{t['theme']} | `#{t['pair'][0]}` / `#{t['pair'][1]}` | #{t['deltaE']} | #{t['hexA']} / #{t['hexB']} |"
          end
        end
        lines << ""
        lines.join("\n")
      end

      def spacing_rhythm_section
        return "_Non mesuré._\n\n" if spacing_histograms.empty?

        lines = [ "| Écran | Valeurs distinctes | Détail |", "| --- | --- | --- |" ]
        spacing_histograms.each do |screen, hist|
          next if hist.empty?

          sorted = hist.sort_by { |value, _| value.to_f }
          detail = sorted.map { |value, count| "#{value}px×#{count}" }.join(", ")
          lines << "| #{screen} | #{hist.size} | #{detail} |"
        end
        lines << ""
        lines.join("\n")
      end
  end
end
