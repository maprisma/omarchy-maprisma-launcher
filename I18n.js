.pragma library

// Interface translations. All built in: nothing is
// downloaded or generated. The language follows the system (LC_ALL,
// LC_MESSAGES, LANG) unless one is picked in the editor; anything without a
// translation falls back to English.

var LANGUAGES = [
  { code: "en", name: "English" },
  { code: "de", name: "Deutsch" },
  { code: "fr", name: "Français" },
  { code: "es", name: "Español" },
  { code: "it", name: "Italiano" },
  { code: "pt", name: "Português" },
  { code: "nl", name: "Nederlands" },
  { code: "pl", name: "Polski" }
]

// "xx_YY.UTF-8" / "xx-YY" / "xx" -> "xx" when we have it, else "en".
function systemLanguage(lcAll, lcMessages, lang) {
  var values = [lcAll, lcMessages, lang]
  for (var i = 0; i < values.length; i++) {
    var code = String(values[i] || "").toLowerCase().split(/[_.@-]/)[0]
    if (code === "c" || code === "posix" || code === "") continue
    return supported(code) ? code : "en"
  }
  return "en"
}

function supported(code) {
  for (var i = 0; i < LANGUAGES.length; i++) if (LANGUAGES[i].code === code) return true
  return false
}

function languageName(code) {
  for (var i = 0; i < LANGUAGES.length; i++) if (LANGUAGES[i].code === code) return LANGUAGES[i].name
  return code
}

// The setting is "auto" (system) or a language code.
function resolve(setting, systemCode) {
  return setting && setting !== "auto" && supported(setting) ? setting : systemCode
}

function format(text, args) {
  return String(text).replace(/\{(\d+)\}/g, function(match, index) {
    var value = args && args[Number(index)]
    return value === undefined || value === null ? match : String(value)
  })
}

function tr(lang, key, args) {
  var table = STRINGS[lang] || STRINGS.en
  var text = table[key]
  if (text === undefined) text = STRINGS.en[key]
  if (text === undefined) return key
  if (Array.isArray(text)) text = text[text.length - 1]
  return format(text, args)
}

// Plural: entries are [one, other], or [one, few, many] for Polish.
function trn(lang, key, n, args) {
  var table = STRINGS[lang] || STRINGS.en
  var forms = table[key] !== undefined ? table[key] : STRINGS.en[key]
  if (forms === undefined) return key
  if (!Array.isArray(forms)) return format(forms, [n].concat(args || []))
  var index
  if (lang === "pl" && forms.length === 3) {
    var mod10 = n % 10, mod100 = n % 100
    index = n === 1 ? 0 : (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) ? 1 : 2
  } else if (lang === "fr" || lang === "pt") {
    index = n <= 1 ? 0 : forms.length - 1
  } else {
    index = n === 1 ? 0 : forms.length - 1
  }
  return format(forms[index], [n].concat(args || []))
}

var STRINGS = {
  en: {
      "settings": "Settings",
      "back": "Back",
      "backTip": "Back (Backspace, Esc)",
      "language": "Language",
      "systemLanguage": "System ({0})",
      "information": "Information",
      "moreTitle": "More plugins by the same author",
      "moreOpenTip": "Open {0} in the Omarchy Plugin Marketplace",
      "moreWlan": "Who is on your Wi-Fi, with a network map",
      "moreTheme": "Every Omarchy theme in one place, with wallpapers",
      "moreBluetooth": "Battery levels of mice, keyboards and headsets",
      "moreLlm": "Which local AI model holds your GPU memory",
      "moreAgents": "Your AI agents, models and MCP servers on one map",
      "moreApps": "Your apps in groups, with shortcuts and a dock",
      "moreWorkspaces": "Window limits and layouts per workspace",
      "moreHue": "Philips Hue rooms and lights from the bar",
      "moreVideo": "Live translated captions for any video or call",
      "moreNarrator": "Reads any window, PDF or Kindle page aloud",
      "moreRecipes": "Your recipes: import, translate and cook",
      "moreMyPlugins": "For plugin authors: views, downloads, status",
      "notInstalled": "Not installed yet",
      "installing": "installing",
      "installedPill": "installed",
      "intro": "Maprisma Launcher is a separate app; this plugin adds its bar icon.",
      "explain": "Install downloads the official AppImage (version {0}, {1} MB) from github.com/maprisma/launcher, checks its SHA-256 fingerprint and saves it as ~/.local/bin/maprisma-launcher. No administrator rights are needed.",
      "install": "Install Maprisma Launcher",
      "installTip": "Download, check and install the app for your user",
      "downloading": "Downloading… {0} of {1} MB",
      "verifying": "Checking the fingerprint…",
      "doneText": "Maprisma Launcher is installed. From now on, a click on the bar icon opens it.",
      "open": "Open Maprisma Launcher",
      "tryAgain": "Try again",
      "removeHint": "To remove it later, delete ~/.local/bin/maprisma-launcher.",
      "errDownload": "The download did not work. Check the internet connection and try again.",
      "errChecksum": "The downloaded file did not match the expected fingerprint and was deleted.",
      "errExists": "Something is already at ~/.local/bin/maprisma-launcher, so nothing was changed.",
      "errArch": "Maprisma Launcher is only available for x86_64 PCs.",
      "errCurl": "The program curl is missing, so nothing can be downloaded.",
      "errOther": "The installation did not work ({0})."
  },
  de: {
      "settings": "Einstellungen",
      "back": "Zurück",
      "backTip": "Zurück (Rücktaste, Esc)",
      "language": "Sprache",
      "systemLanguage": "System ({0})",
      "information": "Information",
      "moreTitle": "Weitere Plugins vom selben Autor",
      "moreOpenTip": "{0} im Omarchy Plugin Marketplace öffnen",
      "moreWlan": "Wer in deinem WLAN ist, mit Netzwerkkarte",
      "moreTheme": "Alle Omarchy-Themes an einem Ort, mit Hintergründen",
      "moreBluetooth": "Akkustand von Mäusen, Tastaturen und Headsets",
      "moreLlm": "Welches lokale KI-Modell deinen GPU-Speicher belegt",
      "moreAgents": "Deine KI-Agenten, Modelle und MCP-Server auf einer Karte",
      "moreApps": "Deine Apps in Gruppen, mit Tastenkürzeln und Dock",
      "moreWorkspaces": "Fensterlimits und Layouts pro Arbeitsbereich",
      "moreHue": "Philips-Hue-Räume und -Lampen aus der Leiste",
      "moreVideo": "Live übersetzte Untertitel für jedes Video und Gespräch",
      "moreNarrator": "Liest jedes Fenster, PDF oder Kindle-Seite vor",
      "moreRecipes": "Deine Rezepte: importieren, übersetzen, kochen",
      "moreMyPlugins": "Für Plugin-Autoren: Aufrufe, Downloads, Status",
      "notInstalled": "Noch nicht installiert",
      "installing": "wird installiert",
      "installedPill": "installiert",
      "intro": "Maprisma Launcher ist eine eigene App; dieses Plugin fügt ihr Leistensymbol hinzu.",
      "explain": "Installieren lädt das offizielle AppImage (Version {0}, {1} MB) von github.com/maprisma/launcher, prüft seinen SHA-256-Fingerabdruck und speichert es als ~/.local/bin/maprisma-launcher. Administratorrechte sind nicht nötig.",
      "install": "Maprisma Launcher installieren",
      "installTip": "Die App für deinen Benutzer laden, prüfen und installieren",
      "downloading": "Wird geladen … {0} von {1} MB",
      "verifying": "Fingerabdruck wird geprüft …",
      "doneText": "Maprisma Launcher ist installiert. Ab jetzt öffnet ein Klick auf das Leistensymbol die App.",
      "open": "Maprisma Launcher öffnen",
      "tryAgain": "Noch einmal versuchen",
      "removeHint": "Zum späteren Entfernen ~/.local/bin/maprisma-launcher löschen.",
      "errDownload": "Das Herunterladen hat nicht geklappt. Prüfe die Internetverbindung und versuche es noch einmal.",
      "errChecksum": "Die geladene Datei passte nicht zum erwarteten Fingerabdruck und wurde gelöscht.",
      "errExists": "Unter ~/.local/bin/maprisma-launcher liegt schon etwas, daher wurde nichts geändert.",
      "errArch": "Maprisma Launcher gibt es nur für x86_64-PCs.",
      "errCurl": "Das Programm curl fehlt, daher kann nichts geladen werden.",
      "errOther": "Die Installation hat nicht geklappt ({0})."
  },
  fr: {
      "settings": "Réglages",
      "back": "Retour",
      "backTip": "Retour (Retour arrière, Échap)",
      "language": "Langue",
      "systemLanguage": "Système ({0})",
      "information": "Informations",
      "moreTitle": "Autres plugins du même auteur",
      "moreOpenTip": "Ouvrir {0} dans l’Omarchy Plugin Marketplace",
      "moreWlan": "Qui est sur votre Wi-Fi, avec une carte du réseau",
      "moreTheme": "Tous les thèmes Omarchy au même endroit, avec fonds d’écran",
      "moreBluetooth": "Batterie des souris, claviers et casques",
      "moreLlm": "Quel modèle d’IA local occupe la mémoire GPU",
      "moreAgents": "Vos agents IA, modèles et serveurs MCP sur une carte",
      "moreApps": "Vos applis en groupes, avec raccourcis et dock",
      "moreWorkspaces": "Limites de fenêtres et dispositions par espace",
      "moreHue": "Pièces et lampes Philips Hue depuis la barre",
      "moreVideo": "Sous-titres traduits en direct pour vidéos et appels",
      "moreNarrator": "Lit à voix haute fenêtres, PDF et pages Kindle",
      "moreRecipes": "Vos recettes : importer, traduire, cuisiner",
      "moreMyPlugins": "Pour les auteurs : vues, téléchargements, statut",
      "notInstalled": "Pas encore installé",
      "installing": "installation",
      "installedPill": "installé",
      "intro": "Maprisma Launcher est une app à part ; ce plugin ajoute son icône à la barre.",
      "explain": "Installer télécharge l'AppImage officielle (version {0}, {1} Mo) depuis github.com/maprisma/launcher, vérifie son empreinte SHA-256 et l'enregistre sous ~/.local/bin/maprisma-launcher. Aucun droit d'administrateur n'est nécessaire.",
      "install": "Installer Maprisma Launcher",
      "installTip": "Télécharger, vérifier et installer l'app pour ton utilisateur",
      "downloading": "Téléchargement… {0} sur {1} Mo",
      "verifying": "Vérification de l'empreinte…",
      "doneText": "Maprisma Launcher est installé. Désormais, un clic sur l'icône de la barre l'ouvre.",
      "open": "Ouvrir Maprisma Launcher",
      "tryAgain": "Réessayer",
      "removeHint": "Pour le retirer plus tard, supprime ~/.local/bin/maprisma-launcher.",
      "errDownload": "Le téléchargement a échoué. Vérifie la connexion internet et réessaie.",
      "errChecksum": "Le fichier téléchargé ne correspondait pas à l'empreinte attendue et a été supprimé.",
      "errExists": "Quelque chose existe déjà sous ~/.local/bin/maprisma-launcher, rien n'a donc été modifié.",
      "errArch": "Maprisma Launcher n'existe que pour les PC x86_64.",
      "errCurl": "Le programme curl est absent, rien ne peut être téléchargé.",
      "errOther": "L'installation a échoué ({0})."
  },
  es: {
      "settings": "Ajustes",
      "back": "Atrás",
      "backTip": "Atrás (Retroceso, Esc)",
      "language": "Idioma",
      "systemLanguage": "Sistema ({0})",
      "information": "Información",
      "moreTitle": "Más plugins del mismo autor",
      "moreOpenTip": "Abrir {0} en el Omarchy Plugin Marketplace",
      "moreWlan": "Quién está en tu Wi-Fi, con mapa de la red",
      "moreTheme": "Todos los temas de Omarchy en un lugar, con fondos",
      "moreBluetooth": "Batería de ratones, teclados y auriculares",
      "moreLlm": "Qué modelo de IA local ocupa la memoria de la GPU",
      "moreAgents": "Tus agentes de IA, modelos y servidores MCP en un mapa",
      "moreApps": "Tus apps en grupos, con atajos y un dock",
      "moreWorkspaces": "Límites de ventanas y diseños por espacio de trabajo",
      "moreHue": "Salas y luces Philips Hue desde la barra",
      "moreVideo": "Subtítulos traducidos en vivo para vídeos y llamadas",
      "moreNarrator": "Lee en voz alta ventanas, PDF y páginas de Kindle",
      "moreRecipes": "Tus recetas: importar, traducir y cocinar",
      "moreMyPlugins": "Para autores de plugins: vistas, descargas, estado",
      "notInstalled": "Aún no instalado",
      "installing": "instalando",
      "installedPill": "instalado",
      "intro": "Maprisma Launcher es una app aparte; este plugin añade su icono a la barra.",
      "explain": "Instalar descarga el AppImage oficial (versión {0}, {1} MB) de github.com/maprisma/launcher, comprueba su huella SHA-256 y lo guarda como ~/.local/bin/maprisma-launcher. No hacen falta permisos de administrador.",
      "install": "Instalar Maprisma Launcher",
      "installTip": "Descargar, comprobar e instalar la app para tu usuario",
      "downloading": "Descargando… {0} de {1} MB",
      "verifying": "Comprobando la huella…",
      "doneText": "Maprisma Launcher está instalado. A partir de ahora, un clic en el icono de la barra lo abre.",
      "open": "Abrir Maprisma Launcher",
      "tryAgain": "Intentar de nuevo",
      "removeHint": "Para quitarlo más tarde, borra ~/.local/bin/maprisma-launcher.",
      "errDownload": "La descarga no funcionó. Comprueba la conexión a internet e inténtalo de nuevo.",
      "errChecksum": "El archivo descargado no coincidía con la huella esperada y se ha borrado.",
      "errExists": "Ya hay algo en ~/.local/bin/maprisma-launcher, así que no se ha cambiado nada.",
      "errArch": "Maprisma Launcher solo está disponible para PC x86_64.",
      "errCurl": "Falta el programa curl, así que no se puede descargar nada.",
      "errOther": "La instalación no funcionó ({0})."
  },
  it: {
      "settings": "Impostazioni",
      "back": "Indietro",
      "backTip": "Indietro (Backspace, Esc)",
      "language": "Lingua",
      "systemLanguage": "Sistema ({0})",
      "information": "Informazioni",
      "moreTitle": "Altri plugin dello stesso autore",
      "moreOpenTip": "Apri {0} nell’Omarchy Plugin Marketplace",
      "moreWlan": "Chi è sul tuo Wi-Fi, con la mappa della rete",
      "moreTheme": "Tutti i temi Omarchy in un posto, con sfondi",
      "moreBluetooth": "Batteria di mouse, tastiere e cuffie",
      "moreLlm": "Quale modello di IA locale occupa la memoria GPU",
      "moreAgents": "I tuoi agenti IA, modelli e server MCP su una mappa",
      "moreApps": "Le tue app in gruppi, con scorciatoie e dock",
      "moreWorkspaces": "Limiti di finestre e layout per area di lavoro",
      "moreHue": "Stanze e luci Philips Hue dalla barra",
      "moreVideo": "Sottotitoli tradotti dal vivo per video e chiamate",
      "moreNarrator": "Legge ad alta voce finestre, PDF e pagine Kindle",
      "moreRecipes": "Le tue ricette: importa, traduci e cucina",
      "moreMyPlugins": "Per autori di plugin: visite, download, stato",
      "notInstalled": "Non ancora installato",
      "installing": "installazione",
      "installedPill": "installato",
      "intro": "Maprisma Launcher è un'app separata; questo plugin aggiunge la sua icona alla barra.",
      "explain": "Installa scarica l'AppImage ufficiale (versione {0}, {1} MB) da github.com/maprisma/launcher, ne verifica l'impronta SHA-256 e la salva come ~/.local/bin/maprisma-launcher. Non servono diritti di amministratore.",
      "install": "Installa Maprisma Launcher",
      "installTip": "Scarica, verifica e installa l'app per il tuo utente",
      "downloading": "Download… {0} di {1} MB",
      "verifying": "Verifica dell'impronta…",
      "doneText": "Maprisma Launcher è installato. D'ora in poi un clic sull'icona della barra lo apre.",
      "open": "Apri Maprisma Launcher",
      "tryAgain": "Riprova",
      "removeHint": "Per rimuoverlo in seguito, elimina ~/.local/bin/maprisma-launcher.",
      "errDownload": "Il download non è riuscito. Controlla la connessione a internet e riprova.",
      "errChecksum": "Il file scaricato non corrispondeva all'impronta prevista ed è stato eliminato.",
      "errExists": "In ~/.local/bin/maprisma-launcher c'è già qualcosa, quindi non è stato cambiato nulla.",
      "errArch": "Maprisma Launcher è disponibile solo per PC x86_64.",
      "errCurl": "Manca il programma curl, quindi non si può scaricare nulla.",
      "errOther": "L'installazione non è riuscita ({0})."
  },
  pt: {
      "settings": "Configurações",
      "back": "Voltar",
      "backTip": "Voltar (Backspace, Esc)",
      "language": "Idioma",
      "systemLanguage": "Sistema ({0})",
      "information": "Informações",
      "moreTitle": "Mais plugins do mesmo autor",
      "moreOpenTip": "Abrir {0} no Omarchy Plugin Marketplace",
      "moreWlan": "Quem está no seu Wi-Fi, com mapa da rede",
      "moreTheme": "Todos os temas do Omarchy num só lugar, com papéis de parede",
      "moreBluetooth": "Bateria de mouses, teclados e fones",
      "moreLlm": "Qual modelo de IA local ocupa a memória da GPU",
      "moreAgents": "Seus agentes de IA, modelos e servidores MCP num mapa",
      "moreApps": "Seus apps em grupos, com atalhos e dock",
      "moreWorkspaces": "Limites de janelas e layouts por área de trabalho",
      "moreHue": "Ambientes e luzes Philips Hue na barra",
      "moreVideo": "Legendas traduzidas ao vivo para vídeos e chamadas",
      "moreNarrator": "Lê em voz alta janelas, PDFs e páginas do Kindle",
      "moreRecipes": "Suas receitas: importar, traduzir e cozinhar",
      "moreMyPlugins": "Para autores de plugins: visitas, downloads, status",
      "notInstalled": "Ainda não instalado",
      "installing": "a instalar",
      "installedPill": "instalado",
      "intro": "O Maprisma Launcher é uma app à parte; este plugin adiciona o seu ícone à barra.",
      "explain": "Instalar transfere o AppImage oficial (versão {0}, {1} MB) de github.com/maprisma/launcher, verifica a sua impressão digital SHA-256 e guarda-o como ~/.local/bin/maprisma-launcher. Não são precisos direitos de administrador.",
      "install": "Instalar o Maprisma Launcher",
      "installTip": "Transferir, verificar e instalar a app para o teu utilizador",
      "downloading": "A transferir… {0} de {1} MB",
      "verifying": "A verificar a impressão digital…",
      "doneText": "O Maprisma Launcher está instalado. A partir de agora, um clique no ícone da barra abre-o.",
      "open": "Abrir o Maprisma Launcher",
      "tryAgain": "Tentar de novo",
      "removeHint": "Para o remover mais tarde, apaga ~/.local/bin/maprisma-launcher.",
      "errDownload": "A transferência falhou. Verifica a ligação à internet e tenta de novo.",
      "errChecksum": "O ficheiro transferido não correspondia à impressão digital esperada e foi apagado.",
      "errExists": "Já existe algo em ~/.local/bin/maprisma-launcher, por isso nada foi alterado.",
      "errArch": "O Maprisma Launcher só está disponível para PCs x86_64.",
      "errCurl": "Falta o programa curl, por isso não é possível transferir nada.",
      "errOther": "A instalação falhou ({0})."
  },
  nl: {
      "settings": "Instellingen",
      "back": "Terug",
      "backTip": "Terug (Backspace, Esc)",
      "language": "Taal",
      "systemLanguage": "Systeem ({0})",
      "information": "Informatie",
      "moreTitle": "Meer plug-ins van dezelfde auteur",
      "moreOpenTip": "{0} openen in de Omarchy Plugin Marketplace",
      "moreWlan": "Wie er op je wifi zit, met een netwerkkaart",
      "moreTheme": "Alle Omarchy-thema’s op één plek, met achtergronden",
      "moreBluetooth": "Batterij van muizen, toetsenborden en headsets",
      "moreLlm": "Welk lokaal AI-model je GPU-geheugen gebruikt",
      "moreAgents": "Je AI-agents, modellen en MCP-servers op één kaart",
      "moreApps": "Je apps in groepen, met sneltoetsen en een dock",
      "moreWorkspaces": "Vensterlimieten en indelingen per werkruimte",
      "moreHue": "Philips Hue-kamers en -lampen vanuit de balk",
      "moreVideo": "Live vertaalde ondertitels bij video’s en gesprekken",
      "moreNarrator": "Leest elk venster, pdf of Kindle-pagina voor",
      "moreRecipes": "Je recepten: importeren, vertalen en koken",
      "moreMyPlugins": "Voor plug-inmakers: weergaven, downloads, status",
      "notInstalled": "Nog niet geïnstalleerd",
      "installing": "installeren",
      "installedPill": "geïnstalleerd",
      "intro": "Maprisma Launcher is een aparte app; deze plugin voegt het balkpictogram toe.",
      "explain": "Installeren downloadt de officiële AppImage (versie {0}, {1} MB) van github.com/maprisma/launcher, controleert de SHA-256-vingerafdruk en slaat hem op als ~/.local/bin/maprisma-launcher. Beheerdersrechten zijn niet nodig.",
      "install": "Maprisma Launcher installeren",
      "installTip": "De app voor je gebruiker downloaden, controleren en installeren",
      "downloading": "Downloaden… {0} van {1} MB",
      "verifying": "Vingerafdruk controleren…",
      "doneText": "Maprisma Launcher is geïnstalleerd. Vanaf nu opent een klik op het balkpictogram de app.",
      "open": "Maprisma Launcher openen",
      "tryAgain": "Opnieuw proberen",
      "removeHint": "Om hem later te verwijderen, wis ~/.local/bin/maprisma-launcher.",
      "errDownload": "Het downloaden is mislukt. Controleer de internetverbinding en probeer het opnieuw.",
      "errChecksum": "Het gedownloade bestand kwam niet overeen met de verwachte vingerafdruk en is verwijderd.",
      "errExists": "Er staat al iets op ~/.local/bin/maprisma-launcher, dus er is niets veranderd.",
      "errArch": "Maprisma Launcher is alleen beschikbaar voor x86_64-pc's.",
      "errCurl": "Het programma curl ontbreekt, dus er kan niets worden gedownload.",
      "errOther": "De installatie is mislukt ({0})."
  },
  pl: {
      "settings": "Ustawienia",
      "back": "Wstecz",
      "backTip": "Wstecz (Backspace, Esc)",
      "language": "Język",
      "systemLanguage": "Systemowy ({0})",
      "information": "Informacje",
      "moreTitle": "Więcej wtyczek tego samego autora",
      "moreOpenTip": "Otwórz {0} w Omarchy Plugin Marketplace",
      "moreWlan": "Kto jest w Twoim Wi-Fi, z mapą sieci",
      "moreTheme": "Wszystkie motywy Omarchy w jednym miejscu, z tapetami",
      "moreBluetooth": "Bateria myszy, klawiatur i słuchawek",
      "moreLlm": "Który lokalny model AI zajmuje pamięć GPU",
      "moreAgents": "Twoi agenci AI, modele i serwery MCP na jednej mapie",
      "moreApps": "Twoje aplikacje w grupach, ze skrótami i dokiem",
      "moreWorkspaces": "Limity okien i układy dla każdego obszaru roboczego",
      "moreHue": "Pokoje i lampy Philips Hue z paska",
      "moreVideo": "Tłumaczone na żywo napisy do filmów i rozmów",
      "moreNarrator": "Czyta na głos okna, PDF-y i strony Kindle",
      "moreRecipes": "Twoje przepisy: import, tłumaczenie, gotowanie",
      "moreMyPlugins": "Dla autorów wtyczek: wyświetlenia, pobrania, status",
      "notInstalled": "Jeszcze nie zainstalowano",
      "installing": "instalowanie",
      "installedPill": "zainstalowano",
      "intro": "Maprisma Launcher to osobna aplikacja; ta wtyczka dodaje jej ikonę na pasku.",
      "explain": "Instalacja pobiera oficjalny AppImage (wersja {0}, {1} MB) z github.com/maprisma/launcher, sprawdza jego odcisk SHA-256 i zapisuje go jako ~/.local/bin/maprisma-launcher. Uprawnienia administratora nie są potrzebne.",
      "install": "Zainstaluj Maprisma Launcher",
      "installTip": "Pobierz, sprawdź i zainstaluj aplikację dla swojego użytkownika",
      "downloading": "Pobieranie… {0} z {1} MB",
      "verifying": "Sprawdzanie odcisku…",
      "doneText": "Maprisma Launcher jest zainstalowany. Od teraz kliknięcie ikony na pasku go otwiera.",
      "open": "Otwórz Maprisma Launcher",
      "tryAgain": "Spróbuj ponownie",
      "removeHint": "Aby go później usunąć, skasuj ~/.local/bin/maprisma-launcher.",
      "errDownload": "Pobieranie się nie udało. Sprawdź połączenie z internetem i spróbuj ponownie.",
      "errChecksum": "Pobrany plik nie pasował do oczekiwanego odcisku i został usunięty.",
      "errExists": "W ~/.local/bin/maprisma-launcher coś już jest, więc niczego nie zmieniono.",
      "errArch": "Maprisma Launcher jest dostępny tylko dla komputerów x86_64.",
      "errCurl": "Brakuje programu curl, więc nie można niczego pobrać.",
      "errOther": "Instalacja się nie udała ({0})."
  }
}

var MORE_PLUGINS = [{"id": "ubruckhaus.wlan-monitor", "name": "WLAN Monitor", "glyph": "󰐻", "key": "moreWlan"}, {"id": "ubruckhaus.theme-manager", "name": "Theme Manager", "glyph": "󰸌", "key": "moreTheme"}, {"id": "ubruckhaus.bluetooth-monitor", "name": "Bluetooth Monitor", "glyph": "󰂯", "key": "moreBluetooth"}, {"id": "ubruckhaus.llm-usage", "name": "LLM Monitor", "glyph": "󰘚", "key": "moreLlm"}, {"id": "ubruckhaus.ai-agents-map", "name": "AI Agents Map", "glyph": "󰚩", "key": "moreAgents"}, {"id": "ubruckhaus.simple-launcher-for-fools", "name": "App Manager", "glyph": "", "key": "moreApps"}, {"id": "ubruckhaus.simple-tile", "name": "Workspace Presets", "glyph": "󰕮", "key": "moreWorkspaces"}, {"id": "ubruckhaus.hue-lights", "name": "Hue Lights", "glyph": "󰌵", "key": "moreHue"}, {"id": "ubruckhaus.video-trans", "name": "Video Trans", "glyph": "", "key": "moreVideo"}, {"id": "ubruckhaus.simple-reader", "name": "Screen Narrator", "glyph": "", "key": "moreNarrator"}, {"id": "ubruckhaus.simple-recipes", "name": "Simple Recipes", "glyph": "󰭼", "key": "moreRecipes"}, {"id": "ubruckhaus.my-plugins", "name": "My Plugins", "glyph": "󰐱", "key": "moreMyPlugins"}]
function moreUrl(id) { return "https://plugins.omarchy.org/plugin.html?id={0}".replace("{0}", encodeURIComponent(id)) }
