# Étape 1 : Utiliser une image Node.js officielle comme base
FROM node:18-alpine

# Étape 2 : Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Étape 3 : Copier les fichiers du projet
COPY package.json .
COPY server.js .

# Étape 4 : Installer les dépendances
RUN npm install

# Étape 5 : Exposer le port que l'app utilise
EXPOSE 5000

# Étape 6 : Commande pour démarrer l'app
CMD ["npm", "start"]