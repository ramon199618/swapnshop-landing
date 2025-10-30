(() => {
  const STORAGE_KEY = 'swapshop_lang';
  const fallback = 'de';

  const t = {
    de: {
      app_name: 'Swap&Shop',
      tagline: 'Tauschen, Verschenken & Verkaufen mit Swipe-Spaß',
      nav_back_home: '← Zurück zur Startseite',
      mission_title: 'Unsere Mission',
      mission_text: 'Swap&Shop macht Tauschen, Verschenken und Verkaufen einfach, schnell – und ein Stück spielerischer. In der App kannst du Artikel sicher anbieten oder finden, per Swipe-Logik matchen, lokale Gruppen gründen und dich vernetzen. Alle Artikel werden gespeichert und sind direkt über die Suche auffindbar – ohne endloses Scrollen.',
      features_title: 'Was macht Swap&Shop einzigartig?',
      f1_title: 'Drei Modi, ein Flow',
      f1_text: 'Tauschen, Verschenken, Verkaufen – gebündelt in einer App.',
      f2_title: 'Swipe-Spaß',
      f2_text: 'Entdecken macht Laune – Matches entstehen in Sekunden.',
      f3_title: 'Smarte Suche',
      f3_text: 'Gespeicherte Artikel sind direkt per Stichwort auffindbar (kein Scroll-Marathon).',
      f4_title: 'Lokale Gruppen',
      f4_text: 'Gründe Communities in deinem Ort/Quartier und vernetze dich gezielt.',
      f5_title: 'Eigener Store',
      f5_text: 'Starte deinen Shop in der App – privat (Secondhand) oder professioneller Auftritt.',
      f6_title: 'Radius & Nähe',
      f6_text: 'Finde Dinge und Menschen in deiner Umgebung.',
      f7_title: 'Fair & zugänglich',
      f7_text: 'Hilf einander, spare Geld – neu kaufen ist nicht immer nötig.',
      safety_hint_title: 'Hinweis zu Sicherheit',
      safety_hint_text: 'Nutzer-Verifizierung und Meldesystem sind geplant/in Arbeit. Wir versprechen hier nichts, was noch nicht live ist.',
      team_title: 'Unser Team',
      team_member_role: 'Gründer & Entwickler',
      values_title: 'Unsere Werte',
      history_title: 'Geschichte',
      history_text: 'Swap&Shop wurde im Juni 2025 gestartet – aus der Idee, das Beste aus lokalen Facebook-Gruppen in eine fokussierte App zu bringen: weniger Chaos, mehr Treffer, direkter Kontakt.',
      future_title: 'Zukunft',
      future_intro: 'Wir arbeiten laufend an neuen Features und suchen Tester:innen für die nächsten Schritte:',
      coming_soon: 'Coming Soon - Bald verfügbar!'
    },
    en: {
      app_name: 'Swap&Shop',
      tagline: 'Swap, Give away & Sell with swipe fun',
      nav_back_home: '← Back to homepage',
      mission_title: 'Our mission',
      mission_text: 'Swap&Shop makes swapping, giving away and selling simple, fast – and a bit playful. Offer or find items safely, match via swipe logic, create local groups and connect. All items are saved and directly searchable – no endless scrolling.',
      features_title: 'What makes Swap&Shop unique?',
      f1_title: 'Three modes, one flow',
      f1_text: 'Swap, Give away, Sell – bundled in one app.',
      f2_title: 'Swipe fun',
      f2_text: 'Exploring is fun – matches happen in seconds.',
      f3_title: 'Smart search',
      f3_text: 'Saved items are instantly searchable by keyword (no scroll marathon).',
      f4_title: 'Local groups',
      f4_text: 'Create communities in your area and connect purposefully.',
      f5_title: 'Your own store',
      f5_text: 'Start your shop – private (secondhand) or professional presence.',
      f6_title: 'Radius & proximity',
      f6_text: 'Find things and people nearby.',
      f7_title: 'Fair & accessible',
      f7_text: 'Help each other, save money – new isn’t always necessary.',
      safety_hint_title: 'Safety note',
      safety_hint_text: 'User verification and reporting are planned/in progress. We don’t promise what isn’t live yet.',
      team_title: 'Our team',
      team_member_role: 'Founder & Developer',
      values_title: 'Our values',
      history_title: 'History',
      history_text: 'Swap&Shop started in June 2025 – to bring the best of local groups into a focused app: less noise, better matches, direct contact.',
      future_title: 'Future',
      future_intro: 'We’re continuously building and looking for testers for the next steps:',
      coming_soon: 'Coming soon'
    },
    fr: {
      app_name: 'Swap&Shop',
      tagline: 'Échanger, donner & vendre avec plaisir de swipe',
      nav_back_home: '← Retour à l’accueil',
      mission_title: 'Notre mission',
      mission_text: 'Swap&Shop rend l’échange, le don et la vente simples, rapides et ludiques. Proposez ou trouvez des articles en toute sécurité, matchez via le swipe, créez des groupes locaux et connectez-vous. Tous les articles sont enregistrés et directement recherchables – sans défilement infini.',
      features_title: 'Ce qui rend Swap&Shop unique',
      f1_title: 'Trois modes, un flux',
      f1_text: 'Échanger, donner, vendre – réunis dans une seule app.',
      f2_title: 'Plaisir de swipe',
      f2_text: 'Découvrir est amusant – les matchs se font en secondes.',
      f3_title: 'Recherche intelligente',
      f3_text: 'Les articles enregistrés sont directement trouvables par mot-clé.',
      f4_title: 'Groupes locaux',
      f4_text: 'Créez des communautés locales et connectez-vous.',
      f5_title: 'Votre boutique',
      f5_text: 'Lancez votre boutique – privée (seconde main) ou professionnelle.',
      f6_title: 'Rayon & proximité',
      f6_text: 'Trouvez des objets et des personnes autour de vous.',
      f7_title: 'Juste & accessible',
      f7_text: 'Aidez-vous, économisez – le neuf n’est pas toujours nécessaire.',
      safety_hint_title: 'Note de sécurité',
      safety_hint_text: 'Vérification des utilisateurs et signalements prévus/en cours. Pas de promesses avant la mise en ligne.',
      team_title: 'Notre équipe',
      team_member_role: 'Fondateur & Développeur',
      values_title: 'Nos valeurs',
      history_title: 'Histoire',
      history_text: 'Swap&Shop a démarré en juin 2025 – pour apporter le meilleur des groupes locaux dans une app centrée : moins de bruit, plus de matchs, contact direct.',
      future_title: 'Futur',
      future_intro: 'Nous avançons en continu et cherchons des testeurs pour les prochaines étapes :',
      coming_soon: 'Bientôt disponible'
    },
    it: {
      app_name: 'Swap&Shop',
      tagline: 'Scambia, regala e vendi con lo swipe',
      nav_back_home: '← Torna alla home',
      mission_title: 'La nostra missione',
      mission_text: 'Swap&Shop rende lo scambio, il regalo e la vendita semplici, veloci e divertenti. Offri o trova articoli in sicurezza, fai match con lo swipe, crea gruppi locali e connettiti. Tutti gli articoli sono salvati e ricercabili subito – senza scorrere all’infinito.',
      features_title: 'Cosa rende unica Swap&Shop',
      f1_title: 'Tre modalità, un solo flusso',
      f1_text: 'Scambio, regalo, vendita – insieme in un’unica app.',
      f2_title: 'Swipe divertente',
      f2_text: 'Scoprire è piacevole – i match nascono in pochi secondi.',
      f3_title: 'Ricerca smart',
      f3_text: 'Gli articoli salvati sono subito ricercabili per parola chiave.',
      f4_title: 'Gruppi locali',
      f4_text: 'Crea community nella tua zona e connettiti.',
      f5_title: 'Il tuo store',
      f5_text: 'Avvia il tuo shop – privato (second hand) o professionale.',
      f6_title: 'Raggio & vicinanza',
      f6_text: 'Trova cose e persone vicino a te.',
      f7_title: 'Equo & accessibile',
      f7_text: 'Aiutatevi, risparmiate – il nuovo non è sempre necessario.',
      safety_hint_title: 'Nota sulla sicurezza',
      safety_hint_text: 'Verifica utenti e segnalazioni sono previsti/in lavorazione. Nessuna promessa prima del live.',
      team_title: 'Il nostro team',
      team_member_role: 'Fondatore & Sviluppatore',
      values_title: 'I nostri valori',
      history_title: 'Storia',
      history_text: 'Swap&Shop è nata a giugno 2025 – per portare il meglio dei gruppi locali in un’app focalizzata: meno caos, più match, contatto diretto.',
      future_title: 'Futuro',
      future_intro: 'Sviluppiamo continuamente e cerchiamo tester per i prossimi passi:',
      coming_soon: 'In arrivo'
    }
  };

  function setLang(lang) {
    const dict = t[lang] || t[fallback];
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      if (dict[key]) {
        el.textContent = dict[key];
      }
    });
    localStorage.setItem(STORAGE_KEY, lang);
  }

  function initLangSelector() {
    const sel = document.getElementById('lang-select');
    if (!sel) return;
    const saved = localStorage.getItem(STORAGE_KEY) || fallback;
    sel.value = saved;
    setLang(saved);
    sel.addEventListener('change', () => setLang(sel.value));
  }

  document.addEventListener('DOMContentLoaded', initLangSelector);
})();


