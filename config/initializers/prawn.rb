# PDF documents use the built-in AFM font (WinAnsi): accented characters render fine;
# strings are stripped of non-representable characters (emoji…).
Prawn::Fonts::AFM.hide_m17n_warning = true if defined?(Prawn::Fonts::AFM)
