// Textes affichés (français). Centralisés ici pour préparer les langues locales (version 3).
// Les textes des fixtures sont affichés tels quels (voir FixtureLoader pour la typographie).

/// Espace insécable (avant « : », « ? », « ! », « % » et à l'intérieur des guillemets).
const String nbsp = ' ';

abstract final class Fr {
  // En-tête
  static String bonjour(String prenom) => 'Bonjour $prenom';
  static String nbZones(int n) => '$n zones';

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

  // Actions non branchées
  static const bientot = 'Disponible dans une prochaine version';

  /// Nombre décimal à la française (1.2 → « 1,2 »).
  static String decimal(double value) => value.toString().replaceAll('.', ',');
}
