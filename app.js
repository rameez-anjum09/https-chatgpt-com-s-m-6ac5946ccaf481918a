/**
 * Storybook Nursery Rhymes - Client Application Controller
 * Handles full 50-rhyme catalog, audio playback, queue, search, filtering,
 * local favorites persistence, lyrics display, and device frames.
 */

// Application State
const state = {
  rhymes: [],
  favorites: new Set(),
  currentRhyme: null,
  activeQueue: [],
  isPlaying: false,
  currentTime: 0,
  duration: 0,
  currentTab: 'home',
  activeCategory: 'All',
  searchQuery: '',
  playerMode: 'watch', // 'watch' or 'lyrics'
  isRepeat: false,
  autoplayNext: true,
  reduceMotion: false,
  sfxEnabled: true,
  isSeeking: false
};

// DOM Elements
const elements = {
  // Screens
  homeScreen: document.getElementById('homeScreen'),
  libraryScreen: document.getElementById('libraryScreen'),
  playerScreen: document.getElementById('playerScreen'),
  favoritesScreen: document.getElementById('favoritesScreen'),
  bottomDock: document.getElementById('bottomDock'),
  settingsModal: document.getElementById('settingsModal'),

  // Home Screen
  homeFavoritesContainer: document.getElementById('homeFavoritesContainer'),
  btnStartSinging: document.getElementById('btnStartSinging'),
  btnOpenSettings: document.getElementById('btnOpenSettings'),
  btnCloseSettings: document.getElementById('btnCloseSettings'),

  // Library Screen
  searchInput: document.getElementById('searchInput'),
  searchClearBtn: document.getElementById('searchClearBtn'),
  categoryChips: document.getElementById('categoryChips'),
  rhymesGrid: document.getElementById('rhymesGrid'),
  emptyResults: document.getElementById('emptyResults'),
  btnClearFilters: document.getElementById('btnClearFilters'),
  btnLibraryBack: document.getElementById('btnLibraryBack'),

  // Player Screen
  btnPlayerBack: document.getElementById('btnPlayerBack'),
  btnPlayerFavorite: document.getElementById('btnPlayerFavorite'),
  playerHeartIcon: document.getElementById('playerHeartIcon'),
  playerHeaderTitle: document.getElementById('playerHeaderTitle'),
  playerFullTitle: document.getElementById('playerFullTitle'),
  playerArtwork: document.getElementById('playerArtwork'),
  missingAudioBadge: document.getElementById('missingAudioBadge'),
  lyricLine1: document.getElementById('lyricLine1'),
  lyricLine2: document.getElementById('lyricLine2'),
  playerLyricsBox: document.getElementById('playerLyricsBox'),
  fullLyricsBox: document.getElementById('fullLyricsBox'),
  fullLyricsContent: document.getElementById('fullLyricsContent'),
  tabWatch: document.getElementById('tabWatch'),
  tabLyrics: document.getElementById('tabLyrics'),
  timeElapsed: document.getElementById('timeElapsed'),
  timeDuration: document.getElementById('timeDuration'),
  progressTrackWrapper: document.getElementById('progressTrackWrapper'),
  progressFill: document.getElementById('progressFill'),
  progressThumb: document.getElementById('progressThumb'),
  btnPrevTrack: document.getElementById('btnPrevTrack'),
  btnPlayPause: document.getElementById('btnPlayPause'),
  btnNextTrack: document.getElementById('btnNextTrack'),
  btnRepeat: document.getElementById('btnRepeat'),
  repeatDot: document.getElementById('repeatDot'),
  playIconSvg: document.getElementById('playIconSvg'),
  pauseIconSvg: document.getElementById('pauseIconSvg'),
  btnMoreRhymes: document.getElementById('btnMoreRhymes'),

  // Favorites Screen
  favoritesGrid: document.getElementById('favoritesGrid'),
  emptyFavorites: document.getElementById('emptyFavorites'),
  btnFavoritesBack: document.getElementById('btnFavoritesBack'),
  btnExploreFromFavorites: document.getElementById('btnExploreFromFavorites'),

  // Settings
  settingAutoplay: document.getElementById('settingAutoplay'),
  settingRepeat: document.getElementById('settingRepeat'),
  settingSfx: document.getElementById('settingSfx'),
  settingReduceMotion: document.getElementById('settingReduceMotion'),
  btnResetFavorites: document.getElementById('btnResetFavorites'),

  // Device switcher
  deviceToolbar: document.getElementById('deviceToolbar'),
  audioPlayer: document.getElementById('audioPlayer')
};

// ==========================================================================
// Initialization & Data Loading
// ==========================================================================
async function initApp() {
  loadStoredPreferences();
  setupEventListeners();

  try {
    const res = await fetch('assets/rhymes_data.json');
    state.rhymes = await res.json();
  } catch (err) {
    console.error('Failed to load rhymes data, using fallback:', err);
  }

  // Initial render
  state.activeQueue = state.rhymes;
  renderHomeFavorites();
  renderLibrary();

  // Set default initial player rhyme
  if (state.rhymes.length > 0) {
    state.currentRhyme = state.rhymes[0];
    updatePlayerUI(state.currentRhyme, false);
  }
}

function loadStoredPreferences() {
  try {
    const savedFavs = localStorage.getItem('storybook_favorites');
    if (savedFavs) {
      state.favorites = new Set(JSON.parse(savedFavs));
    } else {
      // Seed with initial favorites matching reference
      state.favorites = new Set(['twinkle_twinkle', 'baa_baa_black_sheep']);
      saveFavorites();
    }

    const autoplay = localStorage.getItem('setting_autoplay');
    if (autoplay !== null) state.autoplayNext = JSON.parse(autoplay);

    const repeat = localStorage.getItem('setting_repeat');
    if (repeat !== null) state.isRepeat = JSON.parse(repeat);

    const reduceMotion = localStorage.getItem('setting_reduce_motion');
    if (reduceMotion !== null) state.reduceMotion = JSON.parse(reduceMotion);

    elements.settingAutoplay.checked = state.autoplayNext;
    elements.settingRepeat.checked = state.isRepeat;
    elements.settingReduceMotion.checked = state.reduceMotion;
  } catch (e) {
    console.warn('Storage not accessible:', e);
  }
}

function saveFavorites() {
  try {
    localStorage.setItem('storybook_favorites', JSON.stringify(Array.from(state.favorites)));
  } catch (e) {}
}

// ==========================================================================
// Navigation & Screen Management
// ==========================================================================
function navigateToTab(tabName) {
  state.currentTab = tabName;

  // Update Bottom Dock tabs
  document.querySelectorAll('.dock-tab').forEach(tab => {
    tab.classList.toggle('active', tab.dataset.target === tabName);
  });

  // Switch screens
  document.querySelectorAll('.screen-view').forEach(screen => {
    screen.classList.remove('active');
  });

  elements.bottomDock.classList.remove('hidden');

  if (tabName === 'home') {
    elements.homeScreen.classList.add('active');
    renderHomeFavorites();
  } else if (tabName === 'rhymes') {
    elements.libraryScreen.classList.add('active');
    renderLibrary();
  } else if (tabName === 'favorites') {
    elements.favoritesScreen.classList.add('active');
    renderFavorites();
  }
}

function openPlayer(rhyme, autoPlay = true, queue = null) {
  if (queue) {
    state.activeQueue = queue;
  } else if (!state.activeQueue.find(r => r.id === rhyme.id)) {
    state.activeQueue = [rhyme];
  }

  state.currentRhyme = rhyme;

  // Hide bottom dock and display player screen
  elements.bottomDock.classList.add('hidden');
  document.querySelectorAll('.screen-view').forEach(s => s.classList.remove('active'));
  elements.playerScreen.classList.add('active');

  updatePlayerUI(rhyme, autoPlay);

  if (autoPlay && rhyme.hasAudio) {
    playTrack(rhyme);
  } else if (!rhyme.hasAudio) {
    pauseTrack();
  }
}

function closePlayer() {
  // Return to previous active tab
  navigateToTab(state.currentTab);
}

// ==========================================================================
// Audio Playback Engine
// ==========================================================================
function playTrack(rhyme) {
  if (!rhyme || !rhyme.hasAudio) {
    pauseTrack();
    return;
  }

  const audioSrc = `assets/audio/${rhyme.audioFileName}`;
  if (elements.audioPlayer.getAttribute('src') !== audioSrc) {
    elements.audioPlayer.src = audioSrc;
    elements.audioPlayer.load();
  }

  elements.audioPlayer.play().then(() => {
    state.isPlaying = true;
    updatePlayPauseIcons();
    updateCardPlayButtons();
  }).catch(err => {
    console.warn('Playback interrupted or requires gesture:', err);
  });
}

function pauseTrack() {
  elements.audioPlayer.pause();
  state.isPlaying = false;
  updatePlayPauseIcons();
  updateCardPlayButtons();
}

function togglePlayPause() {
  if (!state.currentRhyme) return;

  if (!state.currentRhyme.hasAudio) {
    alert("Audio has not been added for '" + state.currentRhyme.title + "' yet. See MEDIA_CHECKLIST.md to import audio.");
    return;
  }

  if (state.isPlaying) {
    pauseTrack();
  } else {
    playTrack(state.currentRhyme);
  }
}

function playNextTrack() {
  if (!state.currentRhyme || state.activeQueue.length === 0) return;
  const idx = state.activeQueue.findIndex(r => r.id === state.currentRhyme.id);
  const nextIdx = (idx + 1) % state.activeQueue.length;
  const nextRhyme = state.activeQueue[nextIdx];
  openPlayer(nextRhyme, true, state.activeQueue);
}

function playPrevTrack() {
  if (!state.currentRhyme || state.activeQueue.length === 0) return;
  if (state.currentTime > 3.0) {
    elements.audioPlayer.currentTime = 0;
    return;
  }
  const idx = state.activeQueue.findIndex(r => r.id === state.currentRhyme.id);
  const prevIdx = (idx - 1 + state.activeQueue.length) % state.activeQueue.length;
  const prevRhyme = state.activeQueue[prevIdx];
  openPlayer(prevRhyme, true, state.activeQueue);
}

function seekAudio(percent) {
  if (!state.currentRhyme || !state.currentRhyme.hasAudio || !state.duration) return;
  const targetTime = percent * state.duration;
  elements.audioPlayer.currentTime = targetTime;
}

function updatePlayPauseIcons() {
  if (state.isPlaying) {
    elements.playIconSvg.classList.add('hidden');
    elements.pauseIconSvg.classList.remove('hidden');
  } else {
    elements.playIconSvg.classList.remove('hidden');
    elements.pauseIconSvg.classList.add('hidden');
  }
}

function updateCardPlayButtons() {
  document.querySelectorAll('.card-play-btn').forEach(btn => {
    const cardId = btn.dataset.rhymeId;
    const isThisPlaying = state.isPlaying && state.currentRhyme && state.currentRhyme.id === cardId;
    btn.classList.toggle('is-playing', isThisPlaying);

    const svg = btn.querySelector('svg');
    if (isThisPlaying) {
      svg.innerHTML = '<rect x="6" y="4" width="4" height="16" rx="1"/><rect x="14" y="4" width="4" height="16" rx="1"/>';
    } else {
      svg.innerHTML = '<polygon points="5 3 19 12 5 21 5 3"/>';
    }
  });
}

function formatTime(sec) {
  if (isNaN(sec) || sec <= 0) return '0:00';
  const m = Math.floor(sec / 60);
  const s = Math.floor(sec % 60);
  return `${m}:${s < 10 ? '0' : ''}${s}`;
}

// ==========================================================================
// Player UI Rendering
// ==========================================================================
function updatePlayerUI(rhyme, autoPlay) {
  if (!rhyme) return;

  // Header Title
  const shortTitle = rhyme.title.split(' ').slice(0, 2).join(' ');
  elements.playerHeaderTitle.textContent = shortTitle;
  elements.playerFullTitle.textContent = rhyme.title;

  // Artwork
  const artSrc = `assets/rhymes/${rhyme.fullAssetName || rhyme.assetName}`;
  elements.playerArtwork.src = artSrc;
  elements.playerArtwork.alt = rhyme.title;

  // Favorite Heart
  const isFav = state.favorites.has(rhyme.id);
  elements.playerHeartIcon.setAttribute('fill', isFav ? 'white' : 'transparent');
  elements.playerHeartIcon.setAttribute('stroke', 'white');

  // Lyrics Preview Lines
  const lines = (rhyme.lyrics || '').split('\n').filter(l => l.trim().length > 0);
  elements.lyricLine1.textContent = lines[0] || 'Sing along together';
  elements.lyricLine2.textContent = lines[1] || 'With joy and wonder';

  // Full Lyrics
  elements.fullLyricsContent.innerHTML = lines.map(l => `<p>${l}</p>`).join('');

  // Audio State
  if (rhyme.hasAudio) {
    elements.missingAudioBadge.classList.add('hidden');
    state.duration = rhyme.audioDuration || 30;
    elements.timeDuration.textContent = formatTime(state.duration);
    elements.timeElapsed.textContent = '0:00';
    elements.progressFill.style.width = '0%';
    elements.progressThumb.style.left = '0%';
  } else {
    elements.missingAudioBadge.classList.remove('hidden');
    state.duration = 0;
    elements.timeDuration.textContent = '--:--';
    elements.timeElapsed.textContent = '0:00';
    elements.progressFill.style.width = '0%';
    elements.progressThumb.style.left = '0%';
  }
}

// ==========================================================================
// Card Rendering (Home, Library, Favorites)
// ==========================================================================
function createRhymeCardElement(rhyme) {
  const card = document.createElement('div');
  card.className = 'rhyme-card';
  card.dataset.id = rhyme.id;

  const isFav = state.favorites.has(rhyme.id);
  const isThisPlaying = state.isPlaying && state.currentRhyme && state.currentRhyme.id === rhyme.id;

  card.innerHTML = `
    <div class="card-artwork-wrap">
      <img src="assets/rhymes/${rhyme.assetName}" alt="${rhyme.title}" class="card-thumb-img" loading="lazy">
      <button class="card-heart-btn ${isFav ? 'is-fav' : ''}" data-fav-id="${rhyme.id}" aria-label="Favorite">
        <svg viewBox="0 0 24 24">
          <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"></path>
        </svg>
      </button>
      <button class="card-play-btn ${isThisPlaying ? 'is-playing' : ''}" data-rhyme-id="${rhyme.id}" aria-label="Play">
        <svg viewBox="0 0 24 24">
          ${isThisPlaying ?
            '<rect x="6" y="4" width="4" height="16" rx="1"/><rect x="14" y="4" width="4" height="16" rx="1"/>' :
            '<polygon points="5 3 19 12 5 21 5 3"/>'
          }
        </svg>
      </button>
    </div>
    <div class="card-footer">
      <h3 class="card-title">${rhyme.title}</h3>
    </div>
  `;

  // Click card to open player
  card.addEventListener('click', (e) => {
    // If heart clicked, toggle favorite
    if (e.target.closest('.card-heart-btn')) {
      e.stopPropagation();
      toggleFavorite(rhyme.id);
      return;
    }

    // If play button clicked, play/pause
    if (e.target.closest('.card-play-btn')) {
      e.stopPropagation();
      if (state.currentRhyme && state.currentRhyme.id === rhyme.id) {
        togglePlayPause();
      } else {
        openPlayer(rhyme, true);
      }
      return;
    }

    // Open player for this card
    openPlayer(rhyme, true);
  });

  return card;
}

function toggleFavorite(rhymeId) {
  if (state.favorites.has(rhymeId)) {
    state.favorites.delete(rhymeId);
  } else {
    state.favorites.add(rhymeId);
  }
  saveFavorites();

  // Re-render favorites across views
  renderHomeFavorites();
  if (state.currentTab === 'favorites') renderFavorites();

  // Update card buttons
  document.querySelectorAll(`.card-heart-btn[data-fav-id="${rhymeId}"]`).forEach(btn => {
    btn.classList.toggle('is-fav', state.favorites.has(rhymeId));
  });

  // Update player heart if active
  if (state.currentRhyme && state.currentRhyme.id === rhymeId) {
    const isFav = state.favorites.has(rhymeId);
    elements.playerHeartIcon.setAttribute('fill', isFav ? 'white' : 'transparent');
  }
}

// Render Screen 1 Favorites
function renderHomeFavorites() {
  elements.homeFavoritesContainer.innerHTML = '';
  const favRhymes = state.rhymes.filter(r => state.favorites.has(r.id));

  if (favRhymes.length === 0) {
    elements.homeFavoritesContainer.innerHTML = `
      <div style="grid-column: span 2; text-align: center; padding: 20px 8px;">
        <p style="font-weight: 800; font-size: 15px; color: var(--color-dark-navy);">No favorites saved yet</p>
        <p style="font-size: 13px; color: var(--color-navy-muted); margin: 6px 0 12px 0;">Tap the heart on any rhyme to save it here.</p>
        <button class="cta-explore-from-fav" style="padding: 8px 20px; font-size: 13px;" onclick="navigateToTab('rhymes')">Explore Rhymes</button>
      </div>
    `;
    return;
  }

  // Show first 2 favorites as shown in reference design
  favRhymes.slice(0, 2).forEach(rhyme => {
    elements.homeFavoritesContainer.appendChild(createRhymeCardElement(rhyme));
  });
}

// Render Screen 2 Library Grid
function renderLibrary() {
  elements.rhymesGrid.innerHTML = '';

  const query = state.searchQuery.toLowerCase().trim();
  const category = state.activeCategory;

  const filtered = state.rhymes.filter(r => {
    const matchesCat = category === 'All' || r.category === category;
    const matchesSearch = !query || r.title.toLowerCase().includes(query) || (r.lyrics && r.lyrics.toLowerCase().includes(query));
    return matchesCat && matchesSearch;
  });

  if (filtered.length === 0) {
    elements.emptyResults.classList.remove('hidden');
    elements.rhymesGrid.classList.add('hidden');
  } else {
    elements.emptyResults.classList.add('hidden');
    elements.rhymesGrid.classList.remove('hidden');
    filtered.forEach(rhyme => {
      elements.rhymesGrid.appendChild(createRhymeCardElement(rhyme));
    });
  }
}

// Render Screen 4 Favorites Grid
function renderFavorites() {
  elements.favoritesGrid.innerHTML = '';
  const favRhymes = state.rhymes.filter(r => state.favorites.has(r.id));

  if (favRhymes.length === 0) {
    elements.emptyFavorites.classList.remove('hidden');
    elements.favoritesGrid.classList.add('hidden');
  } else {
    elements.emptyFavorites.classList.add('hidden');
    elements.favoritesGrid.classList.remove('hidden');
    favRhymes.forEach(rhyme => {
      elements.favoritesGrid.appendChild(createRhymeCardElement(rhyme));
    });
  }
}

// ==========================================================================
// Event Listeners
// ==========================================================================
function setupEventListeners() {
  // Device toolbar buttons
  document.querySelectorAll('.device-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.device-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      document.body.className = `device-${btn.dataset.device}`;
    });
  });

  // Bottom dock tabs
  document.querySelectorAll('.dock-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      navigateToTab(tab.dataset.target);
    });
  });

  // Home Screen CTA "Start Singing"
  elements.btnStartSinging.addEventListener('click', () => {
    // If current playable rhyme exists, resume it, otherwise open library
    const firstPlayable = state.rhymes.find(r => r.hasAudio);
    if (state.currentRhyme && state.currentRhyme.hasAudio) {
      openPlayer(state.currentRhyme, true);
    } else if (firstPlayable) {
      openPlayer(firstPlayable, true);
    } else {
      navigateToTab('rhymes');
    }
  });

  // Settings Modal
  elements.btnOpenSettings.addEventListener('click', () => {
    elements.settingsModal.classList.remove('hidden');
  });

  elements.btnCloseSettings.addEventListener('click', () => {
    elements.settingsModal.classList.add('hidden');
  });

  elements.btnResetFavorites.addEventListener('click', () => {
    if (confirm('Are you sure you want to remove all saved favorites?')) {
      state.favorites.clear();
      saveFavorites();
      renderHomeFavorites();
      renderLibrary();
      if (state.currentTab === 'favorites') renderFavorites();
      elements.settingsModal.classList.add('hidden');
    }
  });

  // Library Controls
  elements.btnLibraryBack.addEventListener('click', () => {
    navigateToTab('home');
  });

  elements.btnFavoritesBack.addEventListener('click', () => {
    navigateToTab('home');
  });

  elements.btnExploreFromFavorites.addEventListener('click', () => {
    navigateToTab('rhymes');
  });

  elements.searchInput.addEventListener('input', (e) => {
    state.searchQuery = e.target.value;
    elements.searchClearBtn.classList.toggle('hidden', !state.searchQuery);
    renderLibrary();
  });

  elements.searchClearBtn.addEventListener('click', () => {
    elements.searchInput.value = '';
    state.searchQuery = '';
    elements.searchClearBtn.classList.add('hidden');
    renderLibrary();
  });

  elements.btnClearFilters.addEventListener('click', () => {
    elements.searchInput.value = '';
    state.searchQuery = '';
    state.activeCategory = 'All';
    document.querySelectorAll('.chip-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.category === 'All');
    });
    renderLibrary();
  });

  elements.categoryChips.addEventListener('click', (e) => {
    const chip = e.target.closest('.chip-btn');
    if (!chip) return;
    document.querySelectorAll('.chip-btn').forEach(b => b.classList.remove('active'));
    chip.classList.add('active');
    state.activeCategory = chip.dataset.category;
    renderLibrary();
  });

  // Player Controls
  elements.btnPlayerBack.addEventListener('click', () => {
    closePlayer();
  });

  elements.btnMoreRhymes.addEventListener('click', () => {
    closePlayer();
    navigateToTab('rhymes');
  });

  elements.btnPlayerFavorite.addEventListener('click', () => {
    if (state.currentRhyme) {
      toggleFavorite(state.currentRhyme.id);
    }
  });

  elements.btnPlayPause.addEventListener('click', () => {
    togglePlayPause();
  });

  elements.btnNextTrack.addEventListener('click', () => {
    playNextTrack();
  });

  elements.btnPrevTrack.addEventListener('click', () => {
    playPrevTrack();
  });

  elements.btnRepeat.addEventListener('click', () => {
    state.isRepeat = !state.isRepeat;
    elements.repeatDot.classList.toggle('hidden', !state.isRepeat);
    localStorage.setItem('setting_repeat', JSON.stringify(state.isRepeat));
  });

  // Watch / Lyrics Mode Tabs
  elements.tabWatch.addEventListener('click', () => {
    state.playerMode = 'watch';
    elements.tabWatch.classList.add('active');
    elements.tabLyrics.classList.remove('active');
    elements.playerLyricsBox.classList.remove('hidden');
    elements.fullLyricsBox.classList.add('hidden');
  });

  elements.tabLyrics.addEventListener('click', () => {
    state.playerMode = 'lyrics';
    elements.tabLyrics.classList.add('active');
    elements.tabWatch.classList.remove('active');
    elements.playerLyricsBox.classList.add('hidden');
    elements.fullLyricsBox.classList.remove('hidden');
  });

  // Progress Bar Seek Gesture
  const trackWrap = elements.progressTrackWrapper;
  trackWrap.addEventListener('click', (e) => {
    const rect = trackWrap.getBoundingClientRect();
    const percent = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
    seekAudio(percent);
  });

  // Audio Player Engine Events
  elements.audioPlayer.addEventListener('timeupdate', () => {
    state.currentTime = elements.audioPlayer.currentTime;
    if (elements.audioPlayer.duration) {
      state.duration = elements.audioPlayer.duration;
    }

    elements.timeElapsed.textContent = formatTime(state.currentTime);
    elements.timeDuration.textContent = formatTime(state.duration);

    const progress = state.duration > 0 ? (state.currentTime / state.duration) * 100 : 0;
    elements.progressFill.style.width = `${progress}%`;
    elements.progressThumb.style.left = `${progress}%`;
  });

  elements.audioPlayer.addEventListener('ended', () => {
    if (state.isRepeat) {
      elements.audioPlayer.currentTime = 0;
      elements.audioPlayer.play();
    } else if (state.autoplayNext) {
      playNextTrack();
    } else {
      pauseTrack();
    }
  });

  elements.audioPlayer.addEventListener('play', () => {
    state.isPlaying = true;
    updatePlayPauseIcons();
    updateCardPlayButtons();
  });

  elements.audioPlayer.addEventListener('pause', () => {
    state.isPlaying = false;
    updatePlayPauseIcons();
    updateCardPlayButtons();
  });
}

// Boot application
window.addEventListener('DOMContentLoaded', initApp);
