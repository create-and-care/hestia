namespace :visual do
  desc "Headless visual verification pass across all views (measurements + screenshots). Pass 'assert' to skip screenshots and exit non-zero on any violation (CI mode)."
  task :check, [ :mode ] => :environment do |_, args|
    mode = args[:mode] == "assert" ? :assert : :capture
    VisualCheck::Runner.new(mode: mode).call
  end
end
