# FADJA App — coque native Flutter

Cette édition reprend l'interface existante de FADJA et l'intègre dans une application Flutter native, sur le modèle technique du dépôt TekaTech Congo (`INFOTELCOM/Tekatech-congo-mobile`). Elle ne modifie pas le site public ni le dépôt TekaTech.

## Ce que contient le projet
- Application Flutter avec activité de lancement native et icône/nom d'application à finaliser avec les assets de marque.
- Interface FADJA existante embarquée localement dans `assets/www/`.
- Connexion à Supabase configurée avec la clé publishable publique existante (aucune clé `service_role`).
- Navigation arrière, état de chargement, écran d'erreur réseau et ouverture de certains liens externes dans le navigateur.
- Workflow GitHub Actions pour générer un APK Android de test.

## Compiler l'APK sur GitHub
1. Créer un nouveau dépôt, par exemple `INFOTELCOM/FADJA-App-Native`, et y envoyer le contenu de ce dossier.
2. Ouvrir Actions et exécuter **Build FADJA Android APK**.
3. Télécharger l'artefact `fadja-android-apk` sur l'exécution terminée.

## Compiler en local
Installer Flutter stable puis exécuter :
```bash
flutter create --platforms=android,ios,windows,linux,macos .
flutter pub get
flutter run
flutter build apk --release
```

## Limites à connaître
- Le code source est préparé mais un APK compilé n'est pas inclus : la compilation et l'installation réelle doivent être exécutées sur un environnement Android/Flutter.
- La première ouverture, les inscriptions Supabase, le stockage photo et les liens doivent être testés sur téléphone avant diffusion.
- Cette version n'ajoute pas de système de mise à jour automatique natif ni de nouveaux messages administratifs, conformément à la demande de ne pas ajouter ces fonctions pour l'instant.
- Les applications iOS signées nécessitent macOS/Xcode et les certificats Apple.
