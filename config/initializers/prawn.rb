# Les documents PDF utilisent la police AFM intégrée (WinAnsi) : les accents français
# passent ; les chaînes sont nettoyées des caractères non représentables (emoji…).
Prawn::Fonts::AFM.hide_m17n_warning = true if defined?(Prawn::Fonts::AFM)
