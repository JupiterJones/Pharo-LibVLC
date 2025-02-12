"
When you use me: 

1. create an instance of me with #createVLCInstance or #createVLCWithArguments:


example without sugar:

```
VLCLibrary uniqueInstance getVersion.
vlc := VLCLibrary uniqueInstance createVLCInstance.
media := VLCLibrary uniqueInstance mediaNew: vlc path: '/home/badetitou/Musique/Coda.mp3'.
mediaList := VLCLibrary uniqueInstance mediaListNew: vlc.
mediaListPlayer := VLCLibrary uniqueInstance mediaListPlayerNew: vlc.
VLCLibrary uniqueInstance mediaListPlayer: mediaListPlayer setMediaList: mediaList.
VLCLibrary uniqueInstance mediaList: mediaList addMedia: media.
VLCLibrary uniqueInstance mediaListPlayerPlay: mediaListPlayer.
VLCLibrary uniqueInstance mediaListPlayerPause: mediaListPlayer.
```
"
Class {
	#name : #VLCLibrary,
	#superclass : #FFILibrary,
	#category : #'VLC-Library'
}

{ #category : #'class initialization' }
VLCLibrary class >> initialize [
	"reset me when startup"
	Smalltalk addToStartUpList: self.
]

{ #category : #initialization }
VLCLibrary class >> reset [
	<script>
	uniqueInstance := nil
]

{ #category : #'class initialization' }
VLCLibrary class >> setEnvironment [
	"On mac please set VLC plugin path..."

	OSPlatform current isMacOSX
		ifTrue: [ OSEnvironment current
				at: 'VLC_PLUGIN_PATH'
				ifAbsent: [ OSEnvironment current
						setEnv: 'VLC_PLUGIN_PATH'
						value: '/Applications/VLC.app/Contents/MacOS/plugins/' ] ]
]

{ #category : #'class initialization' }
VLCLibrary class >> startUp: isImageStarting [

	isImageStarting ifTrue: [ self reset ]
]

{ #category : #'class initialization' }
VLCLibrary class >> uniqueInstance [ 
	^ uniqueInstance ifNil: [ 
		self setEnvironment.
		VLCLibraryCore uniqueInstance.
		super uniqueInstance ]
]

{ #category : #core }
VLCLibrary >> addIntfTo: aLIBVLCInstance named: name [
	^ self ffiCall: 'void libvlc_release (VLCInstance * aLIBVLCInstance, String name)'
]

{ #category : #'event manager' }
VLCLibrary >> attachToEventManager: anEventManager forEvent: aTypeOfEvent withCallback: aCallbackMethod andData: dataWeWantToCarryWithTheEvent [
	"
	anEventManager := vlc eventManagerListPlayer: aListPlayer.
	vlc
		attachToEventManager: eventManager 
		forEvent: VLCEventTypeEnumeration libvlc_MediaListPlayerNextItemSet
		withCallback: VLCEvent
		andData: 0.0.
	"

	self
		ffiCall:
			'
	int libvlc_event_attach ( void * anEventManager,
	VLCEventTypeEnumeration aTypeOfEvent,
	VLCEventCallback aCallbackMethod,
	float* dataWeWantToCarryWithTheEvent 
)	'
]

{ #category : #time }
VLCLibrary >> clock [
"Return the current time as defined by LibVLC.

The unit is the microsecond. Time increases monotonically (regardless of time zone changes and RTC adjustements). The origin is arbitrary but consistent across the whole system (e.g. the system uptim, the time since the system was booted).

Note
On systems that support it, the POSIX monotonic clock is used."
	^ self ffiCall: 'int64 libvlc_clock(void)	'
]

{ #category : #initialization }
VLCLibrary >> createVLCInstance [
	^ VLCLibrary uniqueInstance createVLCWithArguments: {}.
]

{ #category : #initialization }
VLCLibrary >> createVLCInstanceWithoutVideo [
	^ VLCLibrary uniqueInstance createVLCWithArguments: {'--novideo'}.
]

{ #category : #initialization }
VLCLibrary >> createVLCWithArguments: aCollectionOfString [
	"colArguments := OrderedCollection new.
	colArguments add: '--novideo'.
	vlc := VLCLibrary uniqueInstance initializeVLCWithArguments: colArguments.
	media := vlc mediaFileFromStringLocation: 'https://s6.onlinevideoconverter.com/download?file=d3a0d3e4a0c2f5'.	
	player := vlc createPlayerForMedia: media.
	vlc playMediaPlayer: player.
	vlc pauseMediaPlayer: player.
	vlc isMediaPlayerPlaying: player"

	| externalArray |
	externalArray := (FFIExternalArray externalNewType: 'void*' size: aCollectionOfString size) autoRelease.
	aCollectionOfString withIndexDo: [ :string :index | externalArray at: index put: (ExternalAddress fromString: string) autoRelease ].
	^ self initializeVLCWithArguments: externalArray getHandle andNumberOfArgs: aCollectionOfString size.
]

{ #category : #time }
VLCLibrary >> delay: aTime [
"Return the delay (in microseconds) until a certain timestamp.

# Parameters
	*aTime* timestamp

# 	Returns
	negative if timestamp is in the past, positive if it is in the future
"
	self flag: 'may fail because problem with "static"'.
	^ self ffiCall: 'int64 libvlc_delay(int64 aTime)'
]

{ #category : #'event manager' }
VLCLibrary >> detachToEventManager: anEventManager forEvent: aTypeOfEvent withCallback: aCallbackMethod andData: dataWeWantToCarryWithTheEvent [
	"
	anEventManager := vlc eventManagerListPlayer: aListPlayer.
	vlc
		detachToEventManager: eventManager 
		forEvent: VLCEventTypeEnumeration libvlc_MediaListPlayerNextItemSet
		withCallback: VLCEvent
		andData: 0.0.
	"

	self
		ffiCall:
			'
	void libvlc_event_detach ( void * anEventManager,
	VLCEventTypeEnumeration aTypeOfEvent,
	VLCEventCallback aCallbackMethod,
	float* dataWeWantToCarryWithTheEvent 
)	'
]

{ #category : #core }
VLCLibrary >> free: somePointer [
	^ self ffiCall: 'void libvlc_free (void * somePointer)'
]

{ #category : #core }
VLCLibrary >> getChangeset [

	^ self ffiCall: 'String libvlc_get_changeset()'
]

{ #category : #core }
VLCLibrary >> getCompiler [

	^ self ffiCall: 'String libvlc_get_compiler()'
]

{ #category : #'media player' }
VLCLibrary >> getMediaInsideMediaPlayer: aMediaPlayer [
	^ self ffiCall: 'VLCMedia * libvlc_media_player_get_media(VLCMediaPlayer * aMediaPlayer)'
]

{ #category : #core }
VLCLibrary >> getVersion [

	^ self ffiCall: 'String libvlc_get_version()'
]

{ #category : #initialization }
VLCLibrary >> initialize [
	super initialize.
]

{ #category : #initialization }
VLCLibrary >> initializeVLCWithArguments: aCollectionOfString andNumberOfArgs: sizeOfCollectionOfString [
	^ self ffiCall: 'VLCInstance * libvlc_new(int sizeOfCollectionOfString, void * aCollectionOfString)'
]

{ #category : #'media player - deprecated' }
VLCLibrary >> isMediaPlayerPlaying: aMediaPlayer [
	self deprecated: 'Use mediaPlayerIsPlaying: instead' transformWith: '`@receiver isMediaPlayerPlaying: `@arg' -> '`@receiver mediaPlayerIsPlaying: `@arg'.
	^ self mediaPlayerIsPlaying: aMediaPlayer
]

{ #category : #'accessing platform' }
VLCLibrary >> macLibraryName [
	^ '/Applications/VLC.app/Contents/MacOS/lib/libvlc.dylib'
]

{ #category : #media }
VLCLibrary >> media: aMedia addOption: theOption [
	"Add an option to the media."
	^ self ffiCall: 'void libvlc_media_add_option(VLCMedia * aMedia, String theOption)'
]

{ #category : #media }
VLCLibrary >> media: aMedia addOption: theOption flag: aFlag [
	"Add an option to the media with configurable flags.

This option will be used to determine how the media_player will read the media. This allows to use VLC's advanced reading/streaming options on a per-media basis.

The options are detailed in vlc –long-help, for instance ""--sout-all"". Note that all options are not usable on medias: specifically, due to architectural issues, video-related options such as text renderer options cannot be set on a single media. They must be set on the whole libvlc instance instead."
	^ self ffiCall: 'void libvlc_media_add_option_flag(VLCMedia * aMedia, String theOption, int aFlag)'
]

{ #category : #media }
VLCLibrary >> media: aVLCMedia getMeta: aVLCMeta [ 
	"Read the meta of the media."
	^ self ffiCall: 'String libvlc_media_get_meta(VLCMedia * aVLCMedia, VLCMetaT aVLCMeta)'
]

{ #category : #media }
VLCLibrary >> media: aVLCMedia getStats: aVLCMediaStats [ 
	"Get the current statistics about the media."
	^ self ffiCall: 'bool libvlc_media_get_stats(VLCMedia * aVLCMedia, VLCMediaStats * aVLCMediaStats)'
]

{ #category : #media }
VLCLibrary >> media: aVLCMedia parseWithOptions: aVLCMediaParseFlag timeout: timeout [ 
	"Parse the media asynchronously with options.

This fetches (local or network) art, meta data and/or tracks information.

To track when this is over you can listen to libvlc_MediaParsedChanged event. However if this functions returns an error, you will not receive any events.

It uses a flag to specify parse options (see libvlc_media_parse_flag_t). All these flags can be combined. By default, media is parsed if it's a local file.

Note
    Parsing can be aborted with libvlc_media_parse_stop().

See also
    libvlc_MediaParsedChanged 
    libvlc_media_get_meta 
    libvlc_media_tracks_get 
    libvlc_media_get_parsed_status 
    libvlc_media_parse_flag_t

Parameters
    p_md	media descriptor object
    parse_flag	parse options:
    timeout	maximum time allowed to preparse the media. If -1, the default 'preparse-timeout' option will be used as a timeout. If 0, it will wait indefinitely. If > 0, the timeout will be used (in milliseconds).

Returns
    -1 in case of error, 0 otherwise "
	^ self ffiCall: 'int libvlc_media_parse_with_options (VLCMedia * aVLCMedia, VLCMediaParseFlag aVLCMediaParseFlag, int timeout)'
]

{ #category : #media }
VLCLibrary >> media: aVLCMedia setMeta: aVLCMeta with: newMetaValue [
	"Set the meta of the media (this function will not save the meta, call #mediaSaveMeta: in order to save the meta)."
	^ self ffiCall: 'void libvlc_media_set_meta(VLCMedia * aVLCMedia, VLCMetaT aVLCMeta, String newMetaValue)'
]

{ #category : #media }
VLCLibrary >> media: aVLCMedia setUserData: pUserData [
	"Sets media descriptor's user_data."

	^ self ffiCall: 'void libvlc_media_set_user_data (VLCMedia * aVLCMedia, void * pUserData)'
]

{ #category : #media }
VLCLibrary >> media: aVLCMedia slaveGet: slaves [
	"Get a media descriptor's slave list.

vlc := VLCLibrary uniqueInstance createVLCInstance.
media := vlc createMediaFromPath: '/home/badetitou/Vidéos/Spider-Man.Into.the.Spider-Verse.2018.MULTI.TRUEFRENCH.1080p.BluRay.DTS-HDMA.x264-EXTREME.mkv'.
mediaPlayer := vlc createMediaPlayerFromMedia: media.
media parseLocal.
media parseStatus.

arr := ExternalAddress allocate: ExternalAddress wordSize.
nb := VLCLibrary uniqueInstance media: media slaveGet: arr.
a := (FFIExternalArray fromHandle: arr getHandle type: 'VLCMediaSlave *' size: nb).

desc := VLCMediaDiscovererDescription fromHandle: (a at: 3) getHandle.
desc psz_longname readString.
desc psz_name readString.
	
	
	"

	^ self ffiCall: #(int libvlc_media_slaves_get ( VLCMedia * aVLCMedia , void * * slaves ))
]

{ #category : #media }
VLCLibrary >> media: aVLCMedia slavesAddType: aSlaveType priority: priority uri: uri [
	"Set the meta of the media (this function will not save the meta, call #mediaSaveMeta: in order to save the meta)."
	^ self ffiCall: 'int libvlc_media_slaves_add (VLCMedia * aVLCMedia, VLCMediaSlaveType aSlaveType, uint priority, String uri)'
]

{ #category : #'media discovery' }
VLCLibrary >> mediaDiscovererIsRunning: aVLCMediaDiscoverer [
	"Query if media service discover object is running."
	^ self ffiCall: 'bool libvlc_media_discoverer_is_running (VLCMediaDiscoverer * aVLCMediaDiscoverer)'
]

{ #category : #'media discovery' }
VLCLibrary >> mediaDiscovererMediaList: aVLCMediaDiscoverer [
	"Get media service discover media list."
	^ self ffiCall: 'VLCMediaList * libvlc_media_discoverer_media_list (VLCMediaDiscoverer * aVLCMediaDiscoverer)'
]

{ #category : #'media discovery' }
VLCLibrary >> mediaDiscovererNew: aVLCInstance withName: aName [
	^ self ffiCall: 'VLCMediaDiscoverer * libvlc_media_discoverer_new (VLCInstance * aVLCInstance, String aName)'
]

{ #category : #'media discovery' }
VLCLibrary >> mediaDiscovererRelease: aVLCMediaDiscoverer [
	"Release media discover object."
	^ self ffiCall: 'void libvlc_media_discoverer_release (VLCMediaDiscoverer * aVLCMediaDiscoverer)'
]

{ #category : #'media discovery' }
VLCLibrary >> mediaDiscovererStart: aVLCMediaDiscoverer [
	"Start media discovery."
	^ self ffiCall: 'int libvlc_media_discoverer_start (VLCMediaDiscoverer * aVLCMediaDiscoverer)'
]

{ #category : #'media discovery' }
VLCLibrary >> mediaDiscovererStop: aVLCMediaDiscoverer [
	"Stop media discovery."
	^ self ffiCall: 'void libvlc_media_discoverer_stop (VLCMediaDiscoverer * aVLCMediaDiscoverer)'
]

{ #category : #'media discovery' }
VLCLibrary >> mediaDiscovererlistGet: aVLCInstance category: aVLCMediaDiscovererCategory inDescriptions: value [
	"Get media discoverer services by category.
example:

arr := ExternalAddress allocate: ExternalAddress wordSize.
vlc := VLCLibrary uniqueInstance createVLCInstance.
nb := VLCLibrary uniqueInstance mediaDiscovererlistGet: vlc category: (VLCMediaDiscovererCategory libvlc_media_discoverer_localdirs) inDescriptions: arr.
nb := VLCLibrary uniqueInstance mediaDiscovererlistGet: vlc category: (VLCMediaDiscovererCategory libvlc_media_discoverer_devices) inDescriptions: arr.
nb := VLCLibrary uniqueInstance mediaDiscovererlistGet: vlc category: (VLCMediaDiscovererCategory libvlc_media_discoverer_podcasts) inDescriptions: arr.
nb := VLCLibrary uniqueInstance mediaDiscovererlistGet: vlc category: (VLCMediaDiscovererCategory libvlc_media_discoverer_lan) inDescriptions: arr.

a := (FFIExternalArray fromHandle: arr getHandle type: 'VLCMediaDiscovererDescription *' size: nb).

desc := VLCMediaDiscovererDescription fromHandle: (a at: 3) getHandle.
desc psz_longname readString.
desc psz_name readString."

	^ self
		ffiCall:
			'size_t libvlc_media_discoverer_list_get (VLCInstance * aVLCInstance, VLCMediaDiscovererCategory aVLCMediaDiscovererCategory, void * * value)'
]

{ #category : #'media discovery' }
VLCLibrary >> mediaDiscovererlistRelease: aVLCMediaDiscovererDescription count: aCount [
	"Get media discoverer services by category."

	^ self ffiCall: 'void libvlc_media_discoverer_list_release (VLCMediaDiscovererDescription ** aVLCMediaDiscovererDescription, int count)'
]

{ #category : #media }
VLCLibrary >> mediaDuplicate: aVLCMedia [
	"Get the media resource locator (mrl) from a media descriptor object."
	^ self ffiCall: 'VLCMedia * libvlc_media_duplicate(VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaEventManager: aVLCMedia [
	"Get event manager from media descriptor object."
	^ self ffiCall: 'VLCEventManager * libvlc_media_event_manager (VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaGetDuration: aVLCMedia [
	"Get duration (in ms) of media descriptor object item."
	^ self ffiCall: 'int libvlc_media_get_duration (VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaGetMRL: aVLCMedia [
	"Get the media resource locator (mrl) from a media descriptor object."
	^ self ffiCall: 'String libvlc_media_get_mrl(VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaGetParsedStatus: aVLCMedia [
	"Get Parsed status for media descriptor object."
	^ self ffiCall: 'VLCMediaParsedStatus libvlc_media_get_parsed_status (VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaGetState: aVLCMedia [ 
	"Get current state of media descriptor object."
	^ self ffiCall: 'VLCState libvlc_media_get_state(VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaGetType: aVLCMedia [
	"Get the media type of the media descriptor object."
	^ self ffiCall: 'VLCMediaType libvlc_media_get_type (VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaGetUserData: aVLCMedia [
	"Get media descriptor's user_data."

	^ self ffiCall: 'void * libvlc_media_get_user_data (VLCMedia * aVLCMedia)'
]

{ #category : #'media list' }
VLCLibrary >> mediaList: aVLCMediaList addMedia: aVLCMedia [
	^ self ffiCall: 'int libvlc_media_list_add_media(VLCMediaList * aVLCMediaList, VLCMedia * aVLCMedia)'
]

{ #category : #'media list' }
VLCLibrary >> mediaList: aVLCMediaList indexOfItem: aVLCMedia [
	"Find index position of List media instance in media list."
	^ self ffiCall: 'int libvlc_media_list_index_of_item (VLCMediaList * aVLCMediaList, VLCMedia aVLCMedia)'
]

{ #category : #'media list' }
VLCLibrary >> mediaList: aVLCMediaList insertMedia: aVLCMedia at: anIndex [
"insert media instance in media list on a position The libvlc_media_list_lock should be held upon entering this function."
	^ self ffiCall: 'int libvlc_media_list_insert_media (VLCMediaList * aVLCMediaList, VLCMedia * aVLCMedia, int anIndex)'
]

{ #category : #'media list' }
VLCLibrary >> mediaList: aVLCMediaList itemAtIndex: position [
	"List media instance in media list at a position The libvlc_media_list_lock should be held upon entering this function."
	^ self ffiCall: 'VLCMedia * libvlc_media_list_item_at_index (VLCMediaList * aVLCMediaList, int position)'
]

{ #category : #'media list' }
VLCLibrary >> mediaList:aVLCMediaList removeIndex: position [
	"Get media instance from this media list instance."
	^ self ffiCall: 'int libvlc_media_list_remove_index (VLCMediaList * aVLCMediaList, int position)'
]

{ #category : #'media list' }
VLCLibrary >> mediaList: aVLCMediaList setMedia: aVLCMedia [
	"Associate media instance with this media list instance."
	^ self ffiCall: 'void libvlc_media_list_set_media (VLCMediaList * aVLCMediaList, VLCMedia * aLCMedia)'
]

{ #category : #'media list' }
VLCLibrary >> mediaListCount: aVLCMediaList [
	"Get count on media list items The libvlc_media_list_lock should be held upon entering this function."
	^ self ffiCall: 'int libvlc_media_list_count (VLCMediaList * aVLCMediaList)'
]

{ #category : #'media list' }
VLCLibrary >> mediaListEventManager: aVLCMediaList [
	"Release lock on media list items The libvlc_media_list_lock should be held upon entering this function."
	^ self ffiCall: 'VLCEventManager * libvlc_media_list_event_manager (VLCMediaList * aVLCMediaList)'
]

{ #category : #'media list' }
VLCLibrary >> mediaListIsReadonly: aVLCMediaList [
	"This indicates if this media list is read-only from a user point of view."
	^ self ffiCall: 'bool libvlc_media_list_is_readonly (VLCMediaList * aVLCMediaList)'
]

{ #category : #'media list' }
VLCLibrary >> mediaListLock: aVLCMediaList [
	"Get lock on media list items."
	^ self ffiCall: 'void libvlc_media_list_lock (VLCMediaList * aVLCMediaList)'
]

{ #category : #'media list' }
VLCLibrary >> mediaListMedia: aVLCMediaList [
	"Get media instance from this media list instance."
	^ self ffiCall: 'VLCMedia libvlc_media_list_media (VLCMediaList * aVLCMediaList)'
]

{ #category : #'media list' }
VLCLibrary >> mediaListNew: aVLCInstance [
	"Create an empty media list."
	^ self ffiCall: 'VLCMediaList * libvlc_media_list_new(VLCInstance * aVLCInstance)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayer: aVLCMediaListPlayer playItem: aVLCMedia [
	"Play the given media item."
	^ self ffiCall: 'int libvlc_media_list_player_play_item (VLCMediaListPlayer * aVLCMediaListPlayer, VLCMedia * aVLCMedia)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayer: aVLCMediaListPlayer playItemAtIndex: anIndex [
	"Play media list item at position anIndex.
	
# return 
	0 upon success -1 if the item wasn't found
"
	^ self ffiCall: 'int libvlc_media_list_player_play_item_at_index (VLCMediaListPlayer * aVLCMediaListPlayer, int anIndex)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayer: aMediaListPlayer setMediaList: aMediaList [
	"Replace media player in media_list_player with this instance."
	^ self ffiCall: 'void libvlc_media_list_player_set_media_list (VLCMediaListPlayer * aMediaListPlayer, VLCMediaList * aMediaList)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayer: aVLCMediaListPlayer setMediaPlayer: aVLCMediaPlayer [
	"Replace media player in media_list_player with this instance."
	^ self ffiCall: 'void libvlc_media_list_player_set_media_player (VLCMediaListPlayer * aVLCMediaListPlayer, aVLCMediaPlayer * VLCMediaPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayer: aMediaListPlayer setPause: doPause [
	"Pause or resume media list.
	
	play ~= 0
	pause = 0"
	^ self ffiCall: 'void libvlc_media_list_player_set_pause (VLCMediaListPlayer * aMediaListPlayer, int doPause)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayer: aMediaListPlayer setPlaybackMode: aVLCPlaybackMode [
	"Sets the playback mode for the playlist."

	^ self ffiCall: 'void libvlc_media_list_player_set_playback_mode (VLCMediaListPlayer * aMediaListPlayer, VLCPlaybackMode aVLCPlaybackMode)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerEventManager: aVLCMediaListPlayer [
	"Return the event manager of this media_list_player."
	^ self ffiCall: 'VLCEventManager * libvlc_media_list_player_event_manager (VLCMediaListPlayer * aVLCMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerGetMediaPlayer: aMediaListPlayer [
	"Get media player of the media_list_player instance."
	^ self ffiCall: 'VLCMediaPlayer * libvlc_media_list_player_get_media_player (VLCMediaListPlayer * aMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerGetState: aMediaListPlayer [
	"Get current libvlc_state of media list player."
	^ self ffiCall: 'VLCState libvlc_media_list_player_get_state (VLCMediaListPlayer * aVLCMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerIsPlaying: aVLCMediaListPlayer [
	"Is media list playing?"
	^ self ffiCall: 'bool libvlc_media_list_player_is_playing (VLCMediaListPlayer * aVLCMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerNew: anInstance [
	"Create new media_list_player."
	^ self ffiCall: 'VLCMediaListPlayer * libvlc_media_list_player_new(VLCInstance * anInstance)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerNext: aMediaListPlayer [
	"Play next item from media list."
	^ self ffiCall: 'int libvlc_media_list_player_next (VLCMediaListPlayer * aMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerPause: aMediaListPlayer [
	"Toggle pause (or resume) media list."
	^ self ffiCall: 'void libvlc_media_list_player_pause (VLCMediaListPlayer * aMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerPlay: aMediaListPlayer [
	"Play media list."
	^ self ffiCall: 'void libvlc_media_list_player_play (VLCMediaListPlayer * aMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerPrevious: aMediaListPlayer [
	"Play previous item from media list."
	^ self ffiCall: 'int libvlc_media_list_player_previous (VLCMediaListPlayer * aMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerRelease: aVLCMediaListPlayer [
	"Release a media_list_player after use Decrement the reference count of a media player object."
	^ self ffiCall: 'void libvlc_media_list_player_release (VLCMediaListPlayer * aVLCMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerRetain: aVLCMediaListPlayer [
	"Retain a reference to a media player list object."
	^ self ffiCall: 'void libvlc_media_list_player_retain (VLCMediaListPlayer * aVLCMediaListPlayer)'
]

{ #category : #'media list player' }
VLCLibrary >> mediaListPlayerStop: aMediaListPlayer [
	"Stop playing media list."
	^ self ffiCall: 'void libvlc_media_list_player_stop (VLCMediaListPlayer * aMediaListPlayer)'
]

{ #category : #'media list player - deprecated' }
VLCLibrary >> mediaListPlayerStopAsync: aMediaListPlayer [
	"Stop playing media list."
	^ self mediaListPlayerStop: aMediaListPlayer
]

{ #category : #'media list' }
VLCLibrary >> mediaListRelease: aVLCMediaList [
	^ self ffiCall: 'void libvlc_media_list_release (VLCMediaList * aVLCMediaList)'
]

{ #category : #'media list' }
VLCLibrary >> mediaListRetain: aVLCMediaList [
	^ self ffiCall: 'void libvlc_media_list_retain (VLCMediaList * aVLCMediaList)'
]

{ #category : #'media list' }
VLCLibrary >> mediaListUnlock: aVLCMediaList [
	"Release lock on media list items The libvlc_media_list_lock should be held upon entering this function."
	^ self ffiCall: 'void libvlc_media_list_unlock (VLCMediaList * aVLCMediaList)'
]

{ #category : #media }
VLCLibrary >> mediaNew: aVLCInstance asNode: aNodeNameString [
	"Create a media as an empty node with a given name."
	^ self ffiCall: 'VLCMedia * libvlc_media_new_as_node (VLCInstance * aVLCInstance, String aNodeNameString)'
]

{ #category : #media }
VLCLibrary >> mediaNew: aVLCInstance callbacksOpen: aStringPath read: aReadCallback seek: aSeekCallback close: aCloseCallback opaque: anOpaque [
	"Create a media with custom callbacks to read the data from."
	^ self
		ffiCall:
			'VLCMedia * libvlc_media_new_callbacks (VLCInstance *aVLCInstance, VLCMediaOpenCallback open_cb, VLCMediaReadCallback read_cb, VLCMediaSeekCallback seek_cb, VLCMediaCloseCallback close_cb, void *opaque)'
]

{ #category : #media }
VLCLibrary >> mediaNew: aVLCInstance fd: fileDescriptor [
	"Create a media for an already open file descriptor."
	^ self ffiCall: 'VLCMedia * libvlc_media_new_fd(VLCInstance * aVLCInstance, int fileDescriptor)'
]

{ #category : #media }
VLCLibrary >> mediaNew: aVLCInstance location: aLocation [
	"Create a media with a certain given media resource location, for instance a valid URL."
	^ self ffiCall: 'VLCMedia * libvlc_media_new_location (VLCInstance * aVLCInstance, String aLocation)'
]

{ #category : #media }
VLCLibrary >> mediaNew: aVLCInstance path: aStringPath [
	"Create a media for a certain file path."
	^ self ffiCall: 'VLCMedia * libvlc_media_new_path(VLCInstance * aVLCInstance, String aStringPath)'
]

{ #category : #media }
VLCLibrary >> mediaParseStop: aVLCMedia [
	"Stop the parsing of the media."
	^ self ffiCall: 'void libvlc_media_parse_stop (VLCMedia * aVLCMedia)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayer: aVLCMediaPlayer setFullscreen: aBoolean [

	^ self ffiCall: 'void libvlc_set_fullscreen (VLCMediaPlayer * aVLCMediaPlayer, Boolean aBoolean)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayer: aMediaPlayer setMedia: aVLCMedia [
	^ self ffiCall: 'void libvlc_media_player_get_media (VLCMediaPlayer * aMediaPlayer, VLCMedia * aVLCMedia)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayer: aMediaPlayer setPosition: position fast: fast [
	"Set movie position as percentage between 0.0 and 1.0.

This has no effect if playback is not enabled. This might not work depending on the underlying input format and protocol.

Parameters
    p_mi	the Media Player
    b_fast	prefer fast seeking or precise seeking
    f_pos	the position "
	^ self ffiCall: 'int libvlc_media_player_set_position (VLCMediaPlayer * aMediaPlayer, float position, bool fast)'
]

{ #category : #'audio controls' }
VLCLibrary >> mediaPlayerAudio: aVLCMediaPlayer setMute: mute [
	"Get current mute status."
	^ self ffiCall: 'Boolean libvlc_audio_set_mute (VLCMediaPlayer * aVLCMediaPlayer, int mute)'
]

{ #category : #'audio controls' }
VLCLibrary >> mediaPlayerAudio: aVLCMediaPlayer setTrack: idTrack [
	"Set current audio track."

	^ self ffiCall: 'int libvlc_audio_set_track (VLCMediaPlayer * aVLCMediaPlayer, int idTrack)'
]

{ #category : #'audio controls' }
VLCLibrary >> mediaPlayerAudioGetMute: aVLCMediaPlayer [
	"Get current mute status."
	^ self ffiCall: 'Boolean libvlc_audio_get_mute (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'audio controls' }
VLCLibrary >> mediaPlayerAudioGetTrack: aVLCMediaPlayer [
	"Get current audio track."
	^ self ffiCall: 'int libvlc_audio_get_track (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'audio controls' }
VLCLibrary >> mediaPlayerAudioGetTrackCount: aVLCMediaPlayer [
	"Get number of available audio tracks."
	^ self ffiCall: 'int libvlc_audio_get_track_count (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'audio controls' }
VLCLibrary >> mediaPlayerAudioGetTrackDescription: aVLCMediaPlayer [
	"Get the description of available audio tracks."
	^ self ffiCall: 'VLCTrackDescription * libvlc_audio_get_track_description (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'audio controls' }
VLCLibrary >> mediaPlayerAudioToggleMute: aVLCMediaPlayer [
	"Toggle mute status."
	^ self ffiCall: 'void libvlc_audio_toggle_mute (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerGetFullscreen: aVLCMediaPlayer [

	^ self ffiCall: 'Boolean libvlc_get_fullscreen (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayerGetMedia: aMediaPlayer [
	^ self ffiCall: 'VLCMedia * libvlc_media_player_get_media (VLCMediaPlayer * aMediaPlayer)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayerGetPosition: aMediaPlayer [
	"Get movie position as percentage between 0.0 and 1.0."
	^ self ffiCall: 'float libvlc_media_player_get_position (VLCMediaPlayer * aMediaPlayer)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayerIsPlaying: aMediaPlayer [

	^ self ffiCall: 'bool libvlc_media_player_is_playing(VLCMediaPlayer * aMediaPlayer)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayerNewFromMedia: aVLCMedia [
	"example:
	
	| media player vlc |
	vlc := VLCLibrary uniqueInstance.
	media := vlc mediaFileFromStringPath: '/home/badetitou/Musique/Coda.mp3'.	
	player := vlc mediaPlayerNewFromMedia: media.
	"

	^ self ffiCall: 'VLCMediaPlayer * libvlc_media_player_new_from_media(VLCMedia * aVLCMedia)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayerPause: aMediaPlayer [
	^ self ffiCall: 'void * libvlc_media_player_pause(VLCMediaPlayer * aMediaPlayer)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayerPlay: aMediaPlayer [
	"Play"
	^ self ffiCall: 'int libvlc_media_player_play(VLCMediaPlayer * aMediaPlayer)'
]

{ #category : #'media player' }
VLCLibrary >> mediaPlayerStop: aMediaPlayer [
	^ self ffiCall: 'int libvlc_media_player_stop(VLCMediaPlayer * aMediaPlayer)'
]

{ #category : #'media player - deprecated' }
VLCLibrary >> mediaPlayerStopAsync: aMediaPlayer [
	^ self mediaPlayerStop: aMediaPlayer
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerToggleFullscreen: aVLCMediaPlayer [

	^ self ffiCall: 'void libvlc_toggle_fullscreen (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideo: aVLCMediaPlayer setSpu: spuNumber [ 
	"Get current video subtitle."
	^ self ffiCall: 'int libvlc_video_set_spu (VLCMediaPlayer * aVLCMediaPlayer, int spuNumber)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideo: aVLCMediaPlayer setSpuDelay: aDelay [
	"Get the number of available video subtitles."
	^ self ffiCall: 'int64 libvlc_video_get_spu_delay (VLCMediaPlayer * aVLCMediaPlayer, int64 aDelay)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideo: aVLCMediaPlayer setTrack: trackId [ 
	"Get current video track."
	^ self ffiCall: 'int libvlc_video_set_track (VLCMediaPlayer * aVLCMediaPlayer, int trackId)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideoGetSpu: aVLCMediaPlayer [
	"Get current video subtitle."
	^ self ffiCall: 'int libvlc_video_get_spu (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideoGetSpuCount: aVLCMediaPlayer [
	"Get the number of available video subtitles."
	^ self ffiCall: 'int libvlc_video_get_spu_count (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideoGetSpuDelay: aVLCMediaPlayer [
	"Get the number of available video subtitles."
	^ self ffiCall: 'int64 libvlc_video_get_spu_delay (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideoGetSpuDescription: aVLCMediaPlayer [
	"Get the number of available video subtitles."
	^ self ffiCall: 'VLCTrackDescription * libvlc_video_get_spu_description (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideoGetTrack: aVLCMediaPlayer [
	"Get current video track."
	^ self ffiCall: 'int libvlc_video_get_track (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideoGetTrackCount: aVLCMediaPlayer [
	"Get current video track."
	^ self ffiCall: 'int libvlc_video_get_track_count (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #'video controls' }
VLCLibrary >> mediaPlayerVideoGetTrackDescription: aVLCMediaPlayer [
	"Get current video track."
	^ self ffiCall: 'VLCTrackDescription * libvlc_video_get_track_description (VLCMediaPlayer * aVLCMediaPlayer)'
]

{ #category : #media }
VLCLibrary >> mediaRelease: aVLCMedia [
	"Decrement the reference count of a media descriptor object."
	^ self ffiCall: 'void libvlc_media_release(VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaRetain: aVLCMedia [
	"Retain a reference to a media descriptor object (libvlc_media_t)."
	^ self ffiCall: 'void libvlc_media_retain(VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaSaveMeta: aVLCMedia [ 
	"Save the meta previously set."
	^ self ffiCall: 'int libvlc_media_save_meta(VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaSlavesClear: aVLCMedia [
	^ self ffiCall: 'void libvlc_media_slaves_clear (VLCMedia * aVLCMedia)'
]

{ #category : #media }
VLCLibrary >> mediaSlavesRelease: slaves ofSize: count [
	^ self ffiCall: 'void libvlc_media_slaves_release (libvlc_media_slave_t ** slaves, uint count)'
]

{ #category : #media }
VLCLibrary >> mediaSubitems: aVLCMedia [
	"Get subitems of media descriptor object."
	^ self ffiCall: 'VLCMediaList * libvlc_media_subitems (VLCMedia * aVLCMedia)'
]

{ #category : #'media player - deprecated' }
VLCLibrary >> pauseMediaPlayer: aMediaPlayer [
	self deprecated: 'Use mediaPlayerPause: instead' transformWith: '`@receiver pauseMediaPlayer: `@arg' -> '`@receiver mediaPlayerPause: `@arg'.
	^ self mediaPlayerPause: aMediaPlayer
]

{ #category : #'media player - deprecated' }
VLCLibrary >> playMediaPlayer: aMediaPlayer [
	self deprecated: 'Use mediaPlayerPlay instead' transformWith: '`@receiver playMediaPlayer: `@arg' -> '`@receiver mediaPlayerPlay: `@arg'.
	^ self mediaPlayerPlay: aMediaPlayer
]

{ #category : #'media player' }
VLCLibrary >> positionMediaPlayer: aMediaPlayer [
	"return a value between 0.0 and 1.0"
	^ self ffiCall: 'float libvlc_media_player_get_position(VLCMediaPlayer * aMediaPlayer)'
]

{ #category : #'media player' }
VLCLibrary >> positionMediaPlayer: aMediaPlayer setAt: thePositionAsFloatBetweenOAnd1 [
	"return a value between 0.0 and 1.0"

	^ self ffiCall: 'void libvlc_video_set_callbacks (VLCMediaPlayer * mp, VLCVideoLockCallback lock, VLCVideoUnlockCallback unlock, VLCVideoDisplayCallback display, void * opaque)'
]

{ #category : #core }
VLCLibrary >> release: aLIBVLCInstance [
	^ self ffiCall: 'void libvlc_release (VLCInstance * aLIBVLCInstance)'
]

{ #category : #'media player' }
VLCLibrary >> resetMediaPlayer: aMediaPlayer [
	self positionMediaPlayer: aMediaPlayer setAt: 0.0 
]

{ #category : #core }
VLCLibrary >> retain: aLIBVLCInstance [
	^ self ffiCall: 'voic libvlc_retain (VLCInstance * aLIBVLCInstance)'
]

{ #category : #core }
VLCLibrary >> setAppIdInstance: aVLCInstance id: id version: version icon: icon [ 
	"Sets some meta-information about the application."
	^ self ffiCall: 'void libvlc_set_app_id (lVLCInstance * aVLCInstance, String id, String version, String icon)'
]

{ #category : #core }
VLCLibrary >> setUserAgent: aVLCInstance name: id http: version [
	"Sets the application name."
	^ self ffiCall: 'void libvlc_set_user_agent (VLCInstance_t * aVLCInstance, const char *name, const char *http)'
]

{ #category : #'media player' }
VLCLibrary >> setXWindows: indentifier forMediaPlayer: aMediaPlayer [
	^ self ffiCall: 'void libvlc_media_player_set_xwindow(VLCMediaPlayer * aMediaPlayer, int indentifier)'
]

{ #category : #'accessing platform' }
VLCLibrary >> unix32LibraryName [
	#('/usr/lib/i386-linux-gnu' '/usr/lib32' '/usr/lib' '/snap/vlc/current/usr/lib') , ((OSEnvironment current at: 'LD_LIBRARY_PATH' ifAbsent: [ '' ]) substrings: ':')
		do: [ :path | 
			| libraryPath |
			libraryPath := path asFileReference / 'libvlc.so'.
			libraryPath exists ifTrue: [ ^ libraryPath fullName ] ].
	self error: 'Cannot locate vlc library. Please check if it installed on your system'
]

{ #category : #'accessing platform' }
VLCLibrary >> unix64LibraryName [

	^ FFIUnix64LibraryFinder findAnyLibrary:
		  #( 'libvlc.so' 'libvlc.so.5' )
]

{ #category : #'media player' }
VLCLibrary >> videoSetCallbacksMediaPlayer: aMediaPlayer lockCallback: lock unlockCallback: unlock displayCallback: display opaque: opaque [
	"Set callbacks and private data to render decoded video to a custom area in memory."

	^ self ffiCall: 'void libvlc_video_set_callbacks (VLCMediaPlayer * aMediaPlayer, VLCSDLLock lock, VLCSDLUnlock unlock, VLCSDLDisplay display, VLCSDLContext * opaque)'
]

{ #category : #'media player' }
VLCLibrary >> videoSetFormatMediaPlayer: mp chroma: chroma width: width height: height pitch: pitch [

	^ self ffiCall: 'void libvlc_video_set_format (VLCMediaPlayer * mp, String chroma, int width, int height, int pitch)'
]

{ #category : #'accessing platform' }
VLCLibrary >> win32LibraryName [
	((OSEnvironment current at: 'Path' ifAbsent: [ '' ]) substrings: ';'), {'C:\Program Files\VideoLAN\VLC'}
		do: [ :path | 
			| libraryPath |
			libraryPath := path asFileReference / 'libvlc.dll'.
			libraryPath exists ifTrue: [ ^ libraryPath fullName ] ].
	self error: 'Cannot locate vlc library. Please check if it installed on your system'
]
