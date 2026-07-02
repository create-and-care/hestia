# Enregistre le type MIME PDF pour les exports (listes de courses, mois du calendrier).
Mime::Type.register "application/pdf", :pdf unless Mime::Type.lookup_by_extension(:pdf)
