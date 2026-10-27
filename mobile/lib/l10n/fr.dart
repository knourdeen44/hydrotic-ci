// Textes affichés (français). Centralisés ici pour préparer les langues locales (version 3).
// Les textes des fixtures sont affichés tels quels (voir FixtureLoader pour la typographie).

/// Espace insécable (avant « : », « ? », « ! », « % » et à l'intérieur des guillemets).
const String nbsp = ' ';

abstract final class Fr {
  // En-tête
  static String bonjour(String prenom) => 'Bonjour $prenom';
  static String nbZones(int n) => n > 1 ? '$n zones' : '$n zone';

  // Carte de risque (affiché en majuscules)
  static String demainNiveau(String niveau) => 'Demain · Niveau $niveau';

  // Accueil
  static const aujourdhui = "Aujourd'hui";
  static const signalements = 'Signalements';
  static String confirmes(int n) => '$n confirmés';
  static const pluieTitre = 'Pluie (mm) — 5 derniers jours et prévision';
  static const accesRapide = 'Accès rapide';
  static const actionCarte = 'Carte';
  static const actionSignaler = 'Signaler';
  static const actionConsignes = 'Consignes';

  // Barre de navigation
  static const navAccueil = 'Accueil';
  static const navCarte = 'Carte';
  static const navAlertes = 'Alertes';
  static const navProfil = 'Profil';

  // SOS
  static const sos = 'SOS';
  static const sosSemantique = 'Bouton SOS, maintenir trois secondes';
  static const maintenir3s = 'Maintenir 3${nbsp}s';
  static const statutRecu = 'Reçu';
  static const statutEnRoute = 'En route';
  static const statutSecouru = 'Secouru';

  // Notification (aperçu simulé)
  static const notificationEnTete = 'HYDROTIC CI · maintenant';

  // Consignes
  static const queFaireAvantDemain = 'Que faire avant demain$nbsp?';
  static String consignesPour(String niveau, String zone) => 'Consignes pour le niveau $niveau · $zone';

  // Confirmation communautaire
  static String questionRue(String rue) =>
      'La ${rue[0].toLowerCase()}${rue.substring(1)} est-elle toujours inondée$nbsp?';
  static String vousEtesA(String distance) =>
      'Vous êtes à $distance. Votre réponse aide vos voisins et les secours.';
  static const oui = 'Oui';
  static const non = 'Non';
  static const jeNeSaisPas = 'Je ne sais pas';
  static String signaleIlYA(String il) => 'Signalé il y a $il';
  static String votes(int oui, int non) => '$oui «${nbsp}oui$nbsp» · $non «${nbsp}non$nbsp»';
  static const merci = "Merci, c'est noté$nbsp!";
  static String rueDeuxPoints(String rue) => '$rue$nbsp: ';
  static const inondationConfirmee = 'inondation confirmée';
  static String parHabitants(int n) =>
      " par $n habitants. Les autorités voient l'information sur leur tableau de bord.";
  static String votreFiabilite(double score) => 'Votre fiabilité$nbsp: ${decimal(score)}';

  // Carte schématique
  static const legendeInonde = 'Inondé (confirmé)';
  static const legendeSignalement = 'Signalement';
  static const legendeVous = 'Vous';

  // Écran SOS (M4)
  static const besoinAide = "Besoin d'aide$nbsp?";
  static const maintenezBouton = 'Maintenez le bouton 3 secondes. Votre position sera transmise aux secours.';
  static const positionTrouvee = 'Position GPS trouvée';
  static String precision(double metres, String lieu) =>
      'Précision ±$nbsp${metres.round()}${nbsp}m · $lieu';
  static const personnes = 'Personnes';
  static const blesses = 'Blessés';
  static const hauteurEau = "Hauteur d'eau";
  static const enfantsAges = 'Enfants / âgés';
  static const hauteurs = ['Cheville', 'Genou', 'Taille'];
  static const envoyerParSms = "Pas d'internet$nbsp: envoyer le SOS par SMS";
  static const sosEnvoye = 'SOS envoyé';
  static const restezEnHauteur = 'Restez en hauteur et gardez votre téléphone allumé.';
  static const secoursInformes = 'Les secours sont informés';
  static const positionMiseAJour = 'Votre position est mise à jour toutes les 2 minutes.';
  static const retour = 'Retour';
  static String ouiNon(bool value) => value ? oui : non;

  // M5 — Alertes
  static const voirConsignes = 'Voir les consignes';
  static const historique = 'Historique';
  static const bulletinsOfficiels = 'Bulletins officiels';
  static const bulletinsVide = "Les bulletins de la SODEXAM et de l'ONPC apparaîtront ici.";

  // M6 — Profil
  static String identite(String zone) => 'Citoyenne · $zone';
  static const mesQuartiers = 'Mes quartiers';
  static const modifier = 'Modifier';
  static const canauxAlerte = "Canaux d'alerte";
  static const notifications = 'Notifications';
  static const email = 'E-mail';
  static const alertesRougesToujours = "Les alertes rouges sont toujours affichées dans l'application";
  static const maFiabilite = 'Ma fiabilité';
  static const fiabiliteExplication =
      'Votre score augmente quand vos réponses rejoignent celles de vos voisins.';
  static const numerosUtiles = 'Numéros utiles';
  static const numerosACompleter = 'À compléter avec les numéros officiels vérifiés.';
  static const donneesPersonnelles = 'Données personnelles';
  static const supprimerCompte = 'Supprimer mon compte';
  static const modeDemo = 'Mode démonstration — données fictives';

  // M7 — Signaler
  static const signalerInondation = 'Signaler une inondation';
  static const photoFacultatif = 'Photo (facultatif)';
  static const ajouterPhoto = 'Ajouter une photo';
  static const commentaire = 'Commentaire';
  static const envoyerSignalement = 'Envoyer le signalement';
  static const merciVoisins = 'Merci$nbsp! Vos voisins vont être interrogés.';

  // M0 — Démarrage
  static const nomApp = 'Hydrotic CI';
  static const slogan = 'Prévoir, alerter et secourir face aux inondations';
  static const creerCompte = 'Créer un compte';
  static const dejaUnCompte = "J'ai déjà un compte";
  // Titres de l'étape 2 (« Connexion / inscription » dans la spécification).
  static const inscription = 'Inscription';
  static const connexion = 'Connexion';
  static const autorisations = 'Autorisations';
  static const champEmail = 'E-mail';
  static const champMotDePasse = 'Mot de passe';
  // Libellé non fourni par la spécification : bouton de passage à l'étape suivante.
  static const continuer = 'Continuer';
  static const quelsQuartiers = 'Quels quartiers voulez-vous suivre$nbsp?';
  static const autorisationNotifications =
      'Pour recevoir les alertes de vos quartiers, même application fermée.';
  static const localisation = 'Localisation';
  static const autorisationLocalisation =
      'Uniquement pour signaler, confirmer une inondation ou envoyer un SOS.';
  static const commencer = 'Commencer';

  // Mode démo (menu caché : appui long sur le logo)
  static const modeDemoTitre = 'Mode démonstration';
  static const scenario1 = 'Scénario 1 — Alerte la veille';
  static const scenario2 = 'Scénario 2 — Confirmation rue Ministre';
  static const scenario3 = 'Scénario 3 — SOS';
  static const scenario4 = 'Scénario 4 — Tableau de bord';
  static const reinitialiser = 'Réinitialiser les données';
  static const apercuVerrouille = 'Aperçu écran verrouillé';
  static const scenario4Mobile = 'Scénario 4$nbsp: à lancer depuis le tableau de bord (Ctrl + D)';
  static const jeSuisEnDanger = 'Je suis en danger';
  static String ilYAHeures(int h) => 'il y a $h${nbsp}h';

  // Mode réel (phase 2)
  static const seDeconnecter = 'Se déconnecter';
  static const positionGps = 'Position GPS';
  static const positionInconnue = 'Position inconnue';
  static const positionSignalee = 'Position signalée';
  static const positionIndisponible = 'Position indisponible$nbsp: autorisez la localisation pour signaler.';
  static const connexionRequise = 'Connectez-vous pour envoyer un SOS.';
  static const attributionOsm = '© contributeurs OpenStreetMap';

  // Actions non branchées
  static const bientot = 'Disponible dans une prochaine version';

  /// Nombre décimal à la française (1.2 → « 1,2 »).
  static String decimal(double value) => value.toString().replaceAll('.', ',');
}
