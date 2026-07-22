# Metadata backing the /design-system docs pages. Deliberately not
# ActiveRecord — this is a static catalog of the Ui::*Component library,
# read at boot. Prop tables are never hand-transcribed: they're built by
# reflecting on each component's #initialize signature and its VARIANTS/
# SIZES constants (see Entry#props / #enums), and slot names come straight
# from ViewComponent's own `registered_slots` (see Entry#slots) — so the
# docs can't drift from the code the way a hand-written prop table would.
module DesignSystemRegistry
  Entry = Struct.new(:slug, :name, :category, :description, :usage, :related, :component_class, keyword_init: true) do
    def props
      return [] unless component_class

      component_class.instance_method(:initialize).parameters.filter_map do |kind, name|
        next unless name

        { name: name.to_s, kind: kind, required: kind == :keyreq }
      end
    end

    def enums
      return {} unless component_class

      %i[VARIANTS SIZES].filter_map do |const|
        next unless component_class.const_defined?(const, false)

        [ const.to_s.downcase, component_class.const_get(const).keys ]
      end.to_h
    end

    def slots
      return {} unless component_class.respond_to?(:registered_slots)

      component_class.registered_slots.transform_values { |config| config[:collection] ? "renders_many" : "renders_one" }
    end
  end

  CATEGORIES = [
    "Formulaires & saisie",
    "Overlays & menus",
    "Navigation",
    "Affichage de données",
    "Feedback & mise en page",
    "Conversation"
  ].freeze

  SELECTION_USAGE = "Trois façons de choisir une valeur dans une liste, à ne pas confondre :\n" \
    "Native Select quand la liste est courte et que le <select> natif du système suffit (le plus accessible, le moins de JS).\n" \
    "Select quand il faut un style entièrement maîtrisé (options riches, thème cohérent avec le reste de l'UI).\n" \
    "Combobox quand la liste est longue et qu'il faut pouvoir la filtrer en tapant."

  OVERLAY_USAGE = "Quatre conteneurs déclenchés par un bouton, à choisir selon l'ampleur de l'action :\n" \
    "Dialog pour une action ponctuelle qui reste courte (formulaire simple, confirmation avec contenu).\n" \
    "Alert Dialog uniquement pour confirmer une action destructive ou irréversible — jamais pour autre chose.\n" \
    "Sheet pour un panneau annexe qui garde le contexte de la page visible (filtres, détails d'une ligne).\n" \
    "Drawer sur mobile, ou quand le contenu doit glisser depuis le bas comme une feuille d'action."

  FLOATING_USAGE = "Trois façons de faire apparaître du contenu au survol ou au clic :\n" \
    "Tooltip pour un texte d'aide très court, au survol, sans interaction possible dedans.\n" \
    "Hover Card pour un aperçu plus riche (avatar, description) qui reste au survol.\n" \
    "Popover pour du contenu interactif (formulaire, actions) qui s'ouvre au clic et reste ouvert."

  MENU_USAGE = "Command Menu vs menus classiques : Dropdown Menu et Context Menu conviennent à une liste courte " \
    "d'actions ponctuelles ; Menubar convient à une barre de menus permanente façon application desktop ; " \
    "Command convient dès que la liste est longue et qu'il faut pouvoir la chercher au clavier (⌘K)."

  ENTRIES = [
    # ── Formulaires & saisie ──────────────────────────────────────────
    Entry.new(slug: "button", name: "Button", category: CATEGORIES[0], component_class: Ui::ButtonComponent,
      description: "Déclenche une action ponctuelle ; variants default/secondary/outline/ghost/destructive/link, tailles sm/default/lg/icon."),
    Entry.new(slug: "button-group", name: "Button Group", category: CATEGORIES[0], component_class: Ui::ButtonGroupComponent,
      description: "Regroupe plusieurs boutons liés (ex. sélecteur de période) avec des coins fusionnés."),
    Entry.new(slug: "field", name: "Field", category: CATEGORIES[0], component_class: Ui::FieldComponent,
      description: "Assemble label, contrôle, description et message d'erreur d'un champ de formulaire."),
    Entry.new(slug: "input", name: "Input", category: CATEGORIES[0], component_class: Ui::InputComponent,
      description: "Champ de texte natif stylé, avec état invalid pour signaler une erreur."),
    Entry.new(slug: "input-group", name: "Input Group", category: CATEGORIES[0], component_class: Ui::InputGroupComponent,
      description: "Accole un préfixe ou suffixe (icône, unité, @) à un Input."),
    Entry.new(slug: "textarea", name: "Textarea", category: CATEGORIES[0], component_class: Ui::TextareaComponent,
      description: "Zone de texte multiligne, même traitement visuel que Input."),
    Entry.new(slug: "file-upload", name: "File Upload", category: CATEGORIES[0], component_class: Ui::FileUploadComponent,
      description: "Zone de dépôt de fichier avec glisser-déposer, aperçu (image ou nom de fichier) et suppression."),
    Entry.new(slug: "native-select", name: "Native Select", category: CATEGORIES[0], component_class: Ui::NativeSelectComponent,
      description: "Habille le <select> natif du navigateur — le plus accessible pour une liste courte.", usage: SELECTION_USAGE,
      related: %w[select combobox]),
    Entry.new(slug: "select", name: "Select", category: CATEGORIES[0], component_class: Ui::SelectComponent,
      description: "Sélecteur entièrement stylé pour une liste d'options fermée.", usage: SELECTION_USAGE,
      related: %w[native-select combobox]),
    Entry.new(slug: "combobox", name: "Combobox", category: CATEGORIES[0], component_class: Ui::ComboboxComponent,
      description: "Select filtrable au clavier, pour les listes longues.", usage: SELECTION_USAGE,
      related: %w[select native-select]),
    Entry.new(slug: "checkbox", name: "Checkbox", category: CATEGORIES[0], component_class: Ui::CheckboxComponent,
      description: "Case à cocher pour un choix binaire indépendant."),
    Entry.new(slug: "switch", name: "Switch", category: CATEGORIES[0], component_class: Ui::SwitchComponent,
      description: "Interrupteur on/off, pour un réglage appliqué immédiatement (contrairement à la checkbox, souvent liée à un formulaire)."),
    Entry.new(slug: "radio-group", name: "Radio Group", category: CATEGORIES[0], component_class: Ui::RadioGroupComponent,
      description: "Choix unique parmi un petit nombre d'options toutes visibles."),
    Entry.new(slug: "toggle", name: "Toggle", category: CATEGORIES[0], component_class: Ui::ToggleComponent,
      description: "Bouton à deux états (actif/inactif), pour une action de mise en forme (gras, favori…)."),
    Entry.new(slug: "toggle-group", name: "Toggle Group", category: CATEGORIES[0], component_class: Ui::ToggleGroupComponent,
      description: "Ensemble de Toggle liés, sélection unique ou multiple (ex. alignement de texte)."),
    Entry.new(slug: "theme-toggle", name: "Theme Toggle", category: CATEGORIES[0], component_class: Ui::ThemeToggleComponent,
      description: "Bascule clair / sombre / système en un clic, mémorisée d'une visite à l'autre. Utilisé dans la barre latérale de l'app.",
      related: %w[toggle]),
    Entry.new(slug: "slider", name: "Slider", category: CATEGORIES[0], component_class: Ui::SliderComponent,
      description: "Curseur pour choisir une valeur numérique dans une plage."),
    Entry.new(slug: "input-otp", name: "Input OTP", category: CATEGORIES[0], component_class: Ui::InputOtpComponent,
      description: "Saisie d'un code à usage unique, une case par caractère."),
    Entry.new(slug: "label", name: "Label", category: CATEGORIES[0], component_class: Ui::LabelComponent,
      description: "Libellé accessible associé à un contrôle via for_id."),
    Entry.new(slug: "date-picker", name: "Date Picker", category: CATEGORIES[0], component_class: defined?(Ui::DatePickerComponent) ? Ui::DatePickerComponent : nil,
      description: "Compose Popover et Calendar pour sélectionner une date depuis un champ déclencheur. " \
        "Composant de catalogue (parité shadcn) : aucun formulaire de l'app ne l'utilise, qui préfèrent tous l'<input type=\"date\"> natif via Input."),

    # ── Overlays & menus ──────────────────────────────────────────────
    Entry.new(slug: "dialog", name: "Dialog", category: CATEGORIES[1], component_class: Ui::DialogComponent,
      description: "Fenêtre modale générique pour une action ponctuelle.", usage: OVERLAY_USAGE,
      related: %w[alert-dialog sheet drawer]),
    Entry.new(slug: "alert-dialog", name: "Alert Dialog", category: CATEGORIES[1], component_class: Ui::AlertDialogComponent,
      description: "Modale de confirmation réservée aux actions destructives ou irréversibles. " \
        "Composant de catalogue (parité shadcn) : les suppressions de l'app utilisent toutes le data-turbo-confirm natif de Turbo, plus léger pour une simple confirmation textuelle.",
      usage: OVERLAY_USAGE, related: %w[dialog sheet drawer]),
    Entry.new(slug: "sheet", name: "Sheet", category: CATEGORIES[1], component_class: Ui::SheetComponent,
      description: "Panneau qui glisse depuis un bord de l'écran, garde le contexte de la page visible.", usage: OVERLAY_USAGE,
      related: %w[dialog alert-dialog drawer]),
    Entry.new(slug: "drawer", name: "Drawer", category: CATEGORIES[1], component_class: Ui::DrawerComponent,
      description: "Panneau qui glisse depuis le bas, pattern mobile pour une feuille d'action.", usage: OVERLAY_USAGE,
      related: %w[dialog alert-dialog sheet]),
    Entry.new(slug: "popover", name: "Popover", category: CATEGORIES[1], component_class: Ui::PopoverComponent,
      description: "Contenu interactif ouvert au clic, positionné près de son déclencheur.", usage: FLOATING_USAGE,
      related: %w[tooltip hover-card]),
    Entry.new(slug: "tooltip", name: "Tooltip", category: CATEGORIES[1], component_class: Ui::TooltipComponent,
      description: "Texte d'aide court affiché au survol, sans contenu interactif.", usage: FLOATING_USAGE,
      related: %w[popover hover-card]),
    Entry.new(slug: "hover-card", name: "Hover Card", category: CATEGORIES[1], component_class: Ui::HoverCardComponent,
      description: "Aperçu enrichi (avatar, description) affiché au survol d'un lien.", usage: FLOATING_USAGE,
      related: %w[tooltip popover]),
    Entry.new(slug: "dropdown-menu", name: "Dropdown Menu", category: CATEGORIES[1], component_class: Ui::DropdownMenuComponent,
      description: "Liste d'actions ouverte au clic sur un déclencheur.", usage: MENU_USAGE,
      related: %w[context-menu menubar command]),
    Entry.new(slug: "menubar", name: "Menubar", category: CATEGORIES[1], component_class: Ui::MenubarComponent,
      description: "Barre de menus permanente façon application de bureau.", usage: MENU_USAGE,
      related: %w[dropdown-menu command]),
    Entry.new(slug: "context-menu", name: "Context Menu", category: CATEGORIES[1], component_class: Ui::ContextMenuComponent,
      description: "Menu d'actions ouvert par clic droit sur une zone.", usage: MENU_USAGE,
      related: %w[dropdown-menu]),
    Entry.new(slug: "navigation-menu", name: "Navigation Menu", category: CATEGORIES[1], component_class: Ui::NavigationMenuComponent,
      description: "Barre de navigation principale avec sous-menus déroulants."),
    Entry.new(slug: "command", name: "Command", category: CATEGORIES[1], component_class: Ui::CommandComponent,
      description: "Palette de commandes cherchable au clavier (⌘K).", usage: MENU_USAGE,
      related: %w[dropdown-menu menubar]),
    Entry.new(slug: "code-block", name: "Code Block", category: CATEGORIES[1], component_class: Ui::CodeBlockComponent,
      description: "Encadre un aperçu avec un onglet Code affichant l'extrait ERB exact utilisé pour le générer, plus un bouton de copie — " \
        "c'est le moteur d'affichage de ce catalogue lui-même : chaque page de composant en imbrique un.",
      related: %w[tabs]),
    Entry.new(slug: "sonner", name: "Sonner", category: CATEGORIES[1], component_class: Ui::SonnerComponent,
      description: "File de notifications toast, déclenchée via l'évènement toast:show."),

    # ── Navigation ──────────────────────────────────────────────────────
    Entry.new(slug: "tabs", name: "Tabs", category: CATEGORIES[2], component_class: Ui::TabsComponent,
      description: "Bascule entre plusieurs panneaux de contenu sans changer de page."),
    Entry.new(slug: "breadcrumb", name: "Breadcrumb", category: CATEGORIES[2], component_class: Ui::BreadcrumbComponent,
      description: "Fil d'Ariane indiquant la position dans une hiérarchie de pages."),
    Entry.new(slug: "pagination", name: "Pagination", category: CATEGORIES[2], component_class: Ui::PaginationComponent,
      description: "Navigation entre pages d'une liste découpée en lots."),
    Entry.new(slug: "sidebar", name: "Sidebar", category: CATEGORIES[2], component_class: Ui::SidebarComponent,
      description: "Colonne de navigation repliable, sert de base à la nav de ce site de doc."),
    Entry.new(slug: "item", name: "Item", category: CATEGORIES[2], component_class: Ui::ItemComponent,
      description: "Ligne générique leading/title/description/trailing — sert de brique aux listes (contacts, menus, sidebar)."),
    Entry.new(slug: "carousel", name: "Carousel", category: CATEGORIES[2], component_class: Ui::CarouselComponent,
      description: "Défilement horizontal d'un jeu de diapositives."),

    # ── Affichage de données ────────────────────────────────────────────
    Entry.new(slug: "avatar", name: "Avatar", category: CATEGORIES[3], component_class: Ui::AvatarComponent,
      description: "Image de profil avec repli sur des initiales si src est absent."),
    Entry.new(slug: "badge", name: "Badge", category: CATEGORIES[3], component_class: Ui::BadgeComponent,
      description: "Étiquette compacte de statut ou de catégorie."),
    Entry.new(slug: "kbd", name: "Kbd", category: CATEGORIES[3], component_class: Ui::KbdComponent,
      description: "Représente une touche ou un raccourci clavier."),
    Entry.new(slug: "card", name: "Card", category: CATEGORIES[3], component_class: Ui::CardComponent,
      description: "Conteneur titre/description/footer pour regrouper du contenu lié."),
    Entry.new(slug: "table", name: "Table", category: CATEGORIES[3], component_class: Ui::TableComponent,
      description: "Tableau statique en-têtes + lignes. Pour tri/filtre/pagination, voir Data Table.",
      related: %w[data-table]),
    Entry.new(slug: "data-table", name: "Data Table", category: CATEGORIES[3],
      component_class: defined?(Ui::DataTableComponent) ? Ui::DataTableComponent : nil,
      description: "Table interactive : tri au clic sur l'en-tête, filtre texte, pagination. " \
        "Composant de catalogue (parité shadcn) : aucune liste de l'app n'a encore ce besoin (tri/filtre/pagination combinés) — les listes longues existantes utilisent Item + Pagination.",
      related: %w[table]),
    Entry.new(slug: "chart", name: "Chart", category: CATEGORIES[3], component_class: Ui::ChartComponent,
      description: "Graphique en barres minimal pour une série de valeurs.", related: %w[marker]),
    Entry.new(slug: "calendar", name: "Calendar", category: CATEGORIES[3], component_class: Ui::CalendarComponent,
      description: "Grille mensuelle de sélection de date, brique de base du Date Picker.", related: %w[date-picker]),
    Entry.new(slug: "progress", name: "Progress", category: CATEGORIES[3], component_class: Ui::ProgressComponent,
      description: "Barre de progression déterminée par une valeur 0-100."),
    Entry.new(slug: "typography", name: "Typography", category: CATEGORIES[3],
      component_class: defined?(Ui::TypographyComponent) ? Ui::TypographyComponent : nil,
      description: "Échelle de titres et de texte (h1-h4, lead, large, small, muted, citation, code)."),
    Entry.new(slug: "marker", name: "Marker", category: CATEGORIES[3],
      component_class: defined?(Ui::MarkerComponent) ? Ui::MarkerComponent : nil,
      description: "Point d'annotation coloré pour repérer une valeur sur un Chart ou une carte.", related: %w[chart]),

    # ── Feedback & mise en page ─────────────────────────────────────────
    Entry.new(slug: "alert", name: "Alert", category: CATEGORIES[4], component_class: Ui::AlertComponent,
      description: "Message d'information ou d'avertissement ancré dans la page (non flottant)."),
    Entry.new(slug: "spinner", name: "Spinner", category: CATEGORIES[4], component_class: Ui::SpinnerComponent,
      description: "Indicateur de chargement rotatif."),
    Entry.new(slug: "skeleton", name: "Skeleton", category: CATEGORIES[4], component_class: Ui::SkeletonComponent,
      description: "Silhouette animée d'un contenu en cours de chargement."),
    Entry.new(slug: "separator", name: "Separator", category: CATEGORIES[4], component_class: Ui::SeparatorComponent,
      description: "Ligne de séparation visuelle, horizontale ou verticale."),
    Entry.new(slug: "empty", name: "Empty", category: CATEGORIES[4], component_class: Ui::EmptyComponent,
      description: "État vide : titre, description et action pour une liste sans contenu."),
    Entry.new(slug: "aspect-ratio", name: "Aspect Ratio", category: CATEGORIES[4], component_class: Ui::AspectRatioComponent,
      description: "Contraint son contenu à un ratio largeur/hauteur constant."),
    Entry.new(slug: "scroll-area", name: "Scroll Area", category: CATEGORIES[4], component_class: Ui::ScrollAreaComponent,
      description: "Zone défilante avec une scrollbar fine et stylée."),
    Entry.new(slug: "accordion", name: "Accordion", category: CATEGORIES[4], component_class: Ui::AccordionComponent,
      description: "Panneaux empilés qui se déplient un par un (FAQ, sections détaillées)."),
    Entry.new(slug: "collapsible", name: "Collapsible", category: CATEGORIES[4], component_class: Ui::CollapsibleComponent,
      description: "Un seul bloc de contenu qui se plie/déplie derrière un déclencheur."),
    Entry.new(slug: "resizable", name: "Resizable", category: CATEGORIES[4], component_class: Ui::ResizableComponent,
      description: "Deux panneaux séparés par une poignée redimensionnable au glisser."),
    Entry.new(slug: "direction", name: "Direction", category: CATEGORIES[4], component_class: Ui::DirectionComponent,
      description: "Force le sens de lecture (rtl/ltr) d'un bloc de contenu."),

    # ── Conversation ────────────────────────────────────────────────────
    Entry.new(slug: "attachment", name: "Attachment", category: CATEGORIES[5],
      component_class: defined?(Ui::AttachmentComponent) ? Ui::AttachmentComponent : nil,
      description: "Vignette de fichier joint (nom, taille, retrait) pour un composeur de message."),
    Entry.new(slug: "bubble", name: "Bubble", category: CATEGORIES[5],
      component_class: defined?(Ui::BubbleComponent) ? Ui::BubbleComponent : nil,
      description: "Bulle de message alignée à gauche (assistant) ou à droite (utilisateur).", related: %w[message]),
    Entry.new(slug: "message", name: "Message", category: CATEGORIES[5],
      component_class: defined?(Ui::MessageComponent) ? Ui::MessageComponent : nil,
      description: "Ligne de conversation complète : avatar + Bubble + horodatage.", related: %w[bubble message-scroller]),
    Entry.new(slug: "message-scroller", name: "Message Scroller", category: CATEGORIES[5],
      component_class: defined?(Ui::MessageScrollerComponent) ? Ui::MessageScrollerComponent : nil,
      description: "Conteneur de fil de discussion : ancre le scroll en bas, bouton de retour au dernier message.",
      related: %w[message])
  ].freeze

  def self.all
    ENTRIES
  end

  def self.find(slug)
    ENTRIES.find { |entry| entry.slug == slug }
  end

  def self.grouped_by_category
    ENTRIES.group_by(&:category).sort_by { |category, _| CATEGORIES.index(category) }
  end
end
