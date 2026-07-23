# Global

- Modifie l'ensemble des messages de confirmation de sauvegarde / suppression après alert par des sonner (via UI::)
- Rajouter de l'espacement en bas de chaque vue pour le scroll
- Quand on clique sur un bouton d'action avec redirection ou refresh, il faut qu'on reste sur la même vue ou à minima sur la vue du détail
- Rajouter un affichage soit par liste soit par grid, à implémenter sur les différentes vues où c'est nécessaire + mettre le choix dans le paramètrages du foyer mais également en changement ocassionnel sur les vues au besoin
- Gérer le changement de module quand la sidebar est en mode collapse (fermé)
- Ajouter sur le projet un système pour ajouter des données fictives sur l'ensemble de la base de données de développements si besoin (ex : # Optionally, load demo data rake demo_data:default dans le projet https://github.com/we-promise/sure) > Le but est d'avoir l'ensemble des cas pour faire des tests

# Sidebar

- Remplacer l'image par l'image situé dans app/assets/images/logo.png

# Paramètres du foyer

- Remettre la possibilité de changer le thème dark au light (du code est déjà présent)
- Changer l'alert du bouton 'Régénérer le code' par celui du design system
- Changer l'alert du bouton 'Supprimer le foyer' par celui du design system
- Modifie les boutons 'Créer un autre foyer' et 'Rejoindre un foyer' par des boutons UI::
- Sur son propre compte dans l'onglet 'Membres', ajouter une nouvelle vue pour permettre de modifier les différentes informations de son compte
- Sur les notifications, séparer les notifications par blocs de modules et ajouter un bloc global si la notifications concerne plusieurs modules (à spécifier entre parenthèse pour la notification en question)
- Ajouter un bouton 'Copier' sur le message de confirmation de création de jeton API pour pouvoir le copier plus simplement
- Sur l'onglet 'Modules', faire en sorte qu'il n'y ai pas le trait plus foncés dans les tableaux entre la première et la deuxième ligne
- Sur la roadmap, retirer les dates + on voit le trait qui traverse les icons verts

# Accueil

- Rendre plus petit le bloc 'Inviter un membre' et rajouter un bouton pour copier le code sur le presse-papiers
- Pour le bloc 'Membres', remplacer le tableau par des avatars groups, créer un nouvel UI:: ou modifiant le Ui::AvatarComponent en t'inspirant du Avatar Group : https://ui.shadcn.com/docs/components/base/avatar
- Modifie les boutons 'Créer un autre foyer' et 'Rejoindre un foyer' par des boutons UI::
- J'ai un problème de visuel sur le petit bloc de notifications où un bloc blanc apparait au hover, le retirer
- Retirer la mention 'Foyer actif' et le remplacer par un petit cercle de couleur 'rouge' ou 'vert' à gauche du nom de la famille

# Recherche globale

- Fais en sorte de modifier Ui::CommandComponent afin que la croix de fermeture de la modale soit sur la même ligne que le texte et par au dessus
- Pour le positionnement de la modale, je veux qu'elle soit en 1/4 en top et 3/4 en bottom

# Quotidien > Courses

- Remplacer le bouton actuel 'Catalogue de produits' par un bouton UI:: à côté de 'Nouvelle liste'
- Dans le détail d'une liste, remplacer '← Toutes les listes' par le breadcrumb
- Changer l'alert du bouton 'Supprimer la liste' par celui du design system
- Revoir le formulaire d'ajout d'un article car trop comprimé à cause du nombre de champ
- Quand on valide un article via la checkbox, mettre la date du jour par défaut
- Quand on veut supprimer un article, mettre une alerte ou à minima un bouton pour revenir en arrière
- Dans la sélection d'un produit dans la recherche, on affiche le json, il faut que ça soit un article mais également sans la quantité (actuellement ça : ½ citron · {fruits_legumes: "Fruits & légumes", frais: "Frais", surgeles: "Surgelés", epicerie: "Épicerie", boissons: "Boissons", hygiene: "Hygiène", maison: "Maison", autre: "Autre"}, je veux ça : Citron)

# Quotidien > Frigo

- Dans la sélection d'un produit dans la recherche, retire la quantité pour n'avoir que le nom du produit
- Créer une version light du filemanager qui tiens sur la ligne du formulaire et qui ne dépasse pas en hauteur
- Pour les formulaires d'ajouts pour 'Aliments' et 'Plats préparés', met les formulaires dans une modale et ne laisser qu'un bouton 'Ajouter' quand on veut afficher un des deux formulaires
- Ajouter une confirmation quand on clique sur le bouton 'Ajouter à la liste de course'
- Mettre sous UI:: le bouton 'Modifier' + Mettre le formulaire via une modale et par une page à part entière
- Modifier le bloc 'Recettes réalisables avec ton frigo' par un Ui::MarkerComponent qui pulse avec le nombre de recettes qui peuvent être faite avec les ingrédients dans le frigo, si on clique dessus, on as une modale qui s'affiche avec l'ensemble des recettes possibles

# Quotidien > Recettes

- Met dans un Ui::SheetComponent les filtrages du modules
- Dans le détail d'une recette, remplace "← Toutes les recettes" par un breadcrumb
- Met sous forme de bouton la card "Planifier ce repas"
- Pouvoir appuyer sur le bouton 'esc' pour sortir du mode cuisine + Retirer le bouton "← Retour à la recette" du mode cuisine
- Ajouter une alert de confirmation quand on clique sur le bouton 'Ajouter les ingrédients à la liste de courses'
- Quand on clique sur le bouton d'ajout à la liste de courses, il faudrait afficher un message avec l'affichage des listes déjà existantes si on souhaites les placer dedans
- Mettre sur la même ligne le texte dans la card de découverte de menu et le bouton '+' (gagner de la place)
- Ajouter des nouveaux filtrages (Nombre de personnes / Hashtag)

# Quotidien > Menu

- Remplacer 'Ajouter un repas' par un bouton qui ouvre une modale
- Remplacer 'Repas manquant :' par un message d'erreur via petit 'i'
- Mettre sous bouton les boutons '← Sem. préc.', 'Cette semaine' et 'Sem. suiv. →'
- Ajouter une alert de confirmation quand on clique sur le bouton 'Ajouter les ingrédients à la liste de courses'
- Quand on clique sur le bouton d'ajout à la liste de courses, il faudrait afficher un message avec l'affichage des listes déjà existantes si on souhaites les placer dedans
- Mettre sous forme d'alert le texte : "Les recettes de cette semaine étaient déjà ajoutées à la liste de courses." + Mettre le bouton 'Voir la liste de courses'
- Mettre le formulaire de modification de repas sous forme de modale
- Mettre sous alert le message de suppression d'un repas
- Mettre sous forme d'alert le texte : "Repas mis à jour." et "Repas supprimé."
- Ajouter un bouton pour dire qu'on ne mange pas à la maison un repas (ex : je dîne chez quelqu'un d'autre jeudi soir)
- Rendre les cards retractables par défaut sauf pour la journée en cours

# Quotidien > Tâches

- Retirer l'input 'Emoji'
- Problème d'affichage où le texte 'Aucune tâche.' reste même quand j'ajoute une tâche
- Si on trie, ne pas afficher les catégories ou tâches qui ne sont concernés par le filtrage (ex : ne pas afficher les catégories où je n'ai pas de tâches qui me sont affectés)
- Mettre la modification de tâche sous la forme de modale
- Si on clique sur 'Discuter de ceci', afficher un message pour demander sur quelle conversation le faire / en créer une si l'utilisateur le souhaite
- Remplacer le bouton '← Tâches' par un breadcrumb
- Ne pas permettre de supprimer une catégorie si une tâche est encore présente et non faite dedans
- Changer l'alert du bouton 'Supprimer la tâche' par celui du design system

# Quotidien > Calendrier

- Corriger cette erreur > user: anthonyg AVOID eager loading detected CalendarEvent => [:participants, :event_participants] Remove from your query: .includes([:participants, :event_participants])

# Quotidien > Routines

- Remplacer la card "Nouvelle routine" par une modale d'ajout
- Retirer l'input 'Emoji'
- Mettre le bouton de modification de routine dans une modale + Modifier le bouton '← Routines' pour mettre un breadcrumb
- Mettre un breadcrumb au lieu du bouton '← Routines' dans l'historique des complétions + Mettre cette vue dans une modale
- Mettre sous forme d'alert du design system le bouton "Supprimer cette routine ?"

# Maison > Notes

- Mettre sous forme de modale la card d'ajout d'une note
- Mettre sous forme d'alert du design system le bouton 'Supprimer définitivement cette note ?'
- Mettre une alert de confirmation si on clique sur "-> Tâche"
- Modifier le bouton "← Notes" dans la modification d'une tâche pour la remplacer par un breadcrumb

# Maison > Prestataires

- Ajouter une liste de type de prestataires prédéfinis et avoir un autre qui est un champ input pouvant être rempli au besoin pour créer un nouveau type
- Remplacer l'alert "Supprimer le type « test » ? Les prestataires liés seront décatégorisés." par celle du design system

# Maison > Véhicules

- Ajouter d'autres types de véhicules prédéfinis et avoir un autre qui est un champ input pouvant être rempli au besoin pour créer un nouveau type

# Maison > Cave à vin

- Mettre une modale pour la création d'une nouvelle cave
- Met dans un Ui::SheetComponent un nouveau filtrage avec différents filtrages par rapport aux données des caves / bouteilles
- Faire une recherche dynamique
- Remplacer "← Cave à vin" par un breadcrumb
- Mettre sous forme d'alert du design system le bouton de suppression d'une bouteille
- Mettre une alerte quand on veut sortir une bouteille
- Mettre en place une autocomplétion sur les régions des bouteilles

# Maison > Déchets

- Mettre sous forme de boutons Ui::ButtonComponent les boutons : "← Précédent" / "Aujourd'hui" / "Suivant →"
- Mettre les formulaires d'ajouts "Ajouter une collecte ponctuelle" et "Séries récurrentes" sous la forme de deux modales et ne laisser qu'un bouton "Ajouter"
- Revoir l'affichage des prochaines collectes (via tableau et grid) / Idem pour séries récurrentes
- Mettre sous forme de modal design system l'alert de la suppresion "Supprimer cette collecte ?"

# Maison > Budget

- Retirer l'input 'Emoji'

# Famille > Anniversaires

- Mettre un texte pour le bouton d'ajout d'anniversaire

# Famille > Animaux

- Mettre sous forme de card Ui::CardComponent l'affichage des données
- Mettre sous forme de boutons Ui::ButtonComponent les boutons : "Modifier" / "Supprimer"
- Mettre le formulaire d'ajout d'un vaccin sous la forme d'une modale et ne laisser qu'un bouton "Ajouter" / Faire pareil pour "Traitements" et "Produits récurrents"
- Remplacer "← Tous les animaux" par un breadcrumb
- Remplacer "Gérer les documents →" par un Ui::ButtonComponent
- Rajouter un label sur les input dates car on ne sais pas à quoi ça correspond
- Mettre sous forme d'alert les boutons design system de suppressions

# Famille > Bien-être

- Mettre le graphique "Évolution du poids" sous forme de Graphiques linéaires (courbes)
- J'aime pas l'affichage des données dans "Poids", trouve autre chose
- Pour la partie "Séances de sport", créer des séances types avec plusieurs exercices
- Séparer les "Historique des pesées" et "Historique des séances" dans /wellbeing/history
- Remplacer le bouton "Retour au bien-être" par un breadcrumb
- Pour l'input 'Objectif', mettre un placeholder pour mieux préciser la donnée qu'on attends dedans
- Bascule la modification 'Mon profil' dans les paramétrages de l'utilisateur (Âge / Taille / Sexe / Activité / Poids de départ / Objectif)
- Met dans un Ui::SheetComponent un nouveau filtrage où on affiche la temporalité de la données qu'on souhaite dans ce module

# Social > Messages

- Corrige cette erreur : user: anthony USE eager loading detected Conversation => [:participants] Add to your query: .includes([:participants])
- Remplacer le bouton "← Conversations" par un breadcrumb
- Mettre sous Ui::ButtonComponent les boutons "Réglages" et "Supprimer"
- Mettre l'alert du design system pour le bouton de suppression
- On actualise pas dynamiquement la page quand on envoi un message
- De plus, le texte du message se met sur deux lignes alors qu'il ne faudrait pas (mettre un maximum avant de passer à la ligne)

# Social > Fidélité

- Remplacer le bouton "← Fidélité" et "← Toutes les cartes" par un breadcrumb
- Mettre sous Ui::ButtonComponent le bouton "Modifier"
- Permettre de cliquer sur 'esc' quand on veut sortir du mode plein écran
- Mettre l'alert du design system pour le bouton de suppression

# Social > Cadeaux

- Passer le formulaire de création "Nouvelle liste" par une modale et ne laisser qu'un bouton "Nouvelle liste" en haut de la page
- Ajouter un bouton "Voir plus" pour chaque tableau et ne limiter l'affichage qu'à 10 entrées et mettre par ordre décroissant en temps
- Mettre sous Ui::ButtonComponent le bouton "Modifier"
- Remplacer le bouton "← Cadeaux" par un breadcrumb
- Revoir le formulaire d'ajout d'idées pour qu'il soit plus simple mais également sous la forme d'une modale

# Social > Cercles

- Mettre sous Ui::ButtonComponent les boutons "Rejoindre un cercle", "Quitter ce cercle" et "Paramètres"
- Passer le formulaire de création "Créer un cercle" par une modale et ne laisser qu'un bouton "Créer un cercle" en haut de la page à côté de "Rejoindre un cercle"
- Remplacer le bouton "← Cercles" par un breadcrumb

# Social > Voyages

- Passer le formulaire de création "Nouveau voyage" par une modale et ne laisser qu'un bouton "Nouveau voyage" en haut de la page
- Afficher les dates de voyages dans le calendrier
- Mettre sous forme de card les voyages individuellement
- Remplacer le bouton "← Voyages" et "← Projets partagés" par un breadcrumb
- Mettre l'alert du design system pour le bouton de suppression
- Revoir le formulaire de partage des dépenses pour les voyages pour qu'il soit plus simple / ergonomique
