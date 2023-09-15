# Demyx
# https://demyx.sh
# 
# Docker container naming scheme
# https://github.com/moby/moby/blob/master/pkg/namesgenerator/names-generator.go
#
#	Loops until a word/name is present.
#
demyx_name() {
	local DEMYX_NAME_LEFT=
    local DEMYX_NAME_RIGHT=

	while true; do
		DEMYX_NAME_LEFT="$(demyx_name_adjectives)"
		[[ -n "$DEMYX_NAME_LEFT" ]] && break
	done

	while true; do
		DEMYX_NAME_RIGHT="$(demyx_name_sur)"
		[[ -n "$DEMYX_NAME_RIGHT" ]] && break
	done

	echo "${DEMYX_NAME_LEFT}_${DEMYX_NAME_RIGHT}"
}
demyx_name_adjectives() {
    IFS=$'\r\n' GLOBIGNORE='*' command eval 'DEMYX_NAME_ADJECTIVES=(admiring
        adoring
        affectionate
        agitated
        amazing
        angry
        awesome
        beautiful
        blissful
        bold
        boring
        brave
        busy
        charming
        clever
        cool
        compassionate
        competent
        condescending
        confident
        cranky
        crazy
        dazzling
        determined
        distracted
        dreamy
        eager
        ecstatic
        elastic
        elated
        elegant
        eloquent
        epic
        exciting
        fervent
        festive
        flamboyant
        focused
        friendly
        frosty
        funny
        gallant
        gifted
        goofy
        gracious
        great
        happy
        hardcore
        heuristic
        hopeful
        hungry
        infallible
        inspiring
        interesting
        intelligent
        jolly
        jovial
        keen
        kind
        laughing
        loving
        lucid
        magical
        mystifying
        modest
        musing
        naughty
        nervous
        nice
        nifty
        nostalgic
        objective
        optimistic
        peaceful
        pedantic
        pensive
        practical
        priceless
        quirky
        quizzical
        recursing
        relaxed
        reverent
        romantic
        sad
        serene
        sharp
        silly
        sleepy
        stoic
        strange
        stupefied
        suspicious
        sweet
        tender
        thirsty
        trusting
        unruffled
        upbeat
        vibrant
        vigilant
        vigorous
        wizardly
        wonderful
        xenodochial
        youthful
        zealous
        zen)'
    DEMYX_NAME_ADJECTIVES_COUNT="${#DEMYX_NAME_ADJECTIVES[@]}"
    DEMYX_NAME_ADJECTIVES_RANDOM="$(((RANDOM % "$DEMYX_NAME_ADJECTIVES_COUNT")+1))"
    echo "${DEMYX_NAME_ADJECTIVES[$DEMYX_NAME_ADJECTIVES_RANDOM]}"
}

demyx_name_sur() {
    IFS=$'\r\n' GLOBIGNORE='*' command eval 'DEMYX_NAME_SUR=(albattani
		allen
		almeida
		antonelli
		agnesi
		archimedes
		ardinghelli
		aryabhata
		austin
		babbage
		banach
		banzai
		bardeen
		bartik
		bassi
		beaver
		bell
		benz
		bhabha
		bhaskara
		black
		blackburn
		blackwell
		bohr
		booth
		borg
		bose
		bouman
		boyd
		brahmagupta
		brattain
		brown
		buck
		burnell
		cannon
		carson
		cartwright
		cerf
		chandrasekhar
		chaplygin
		chatelet
		chatterjee
		chebyshev
		cohen
		chaum
		clarke
		colden
		cori
		cray
		curran
		curie
		darwin
		davinci
		dewdney
		dhawan
		diffie
		dijkstra
		dirac
		driscoll
		dubinsky
		easley
		edison
		einstein
		elbakyan
		elgamal
		elion
		ellis
		engelbart
		euclid
		euler
		faraday
		feistel
		fermat
		fermi
		feynman
		franklin
		gagarin
		galileo
		galois
		ganguly
		gates
		gauss
		germain
		goldberg
		goldstine
		goldwasser
		golick
		goodall
		gould
		greider
		grothendieck
		haibt
		hamilton
		haslett
		hawking
		hellman
		heisenberg
		hermann
		herschel
		hertz
		heyrovsky
		hodgkin
		hofstadter
		hoover
		debugging
		hopper
		hugle
		hypatia
		ishizaka
		jackson
		jang
		jennings
		jepsen
		johnson
		joliot
		jones
		kalam
		kapitsa
		kare
		keldysh
		keller
		kepler
		khayyam
		khorana
		kilby
		kirch
		knuth
		kowalevski
		lalande
		lamarr
		lamport
		leakey
		leavitt
		lederberg
		lehmann
		lewin
		lichterman
		liskov
		lovelace
		lumiere
		mahavira
		margulis
		matsumoto
		maxwell
		mayer
		mccarthy
		mcclintock
		mclaren
		mclean
		mcnulty
		mendel
		mendeleev
		meitner
		meninsky
		merkle
		mestorf
		mirzakhani
		moore
		morse
		murdock
		moser
		napier
		nash
		neumann
		newton
		nightingale
		nobel
		noether
		northcutt
		noyce
		panini
		pare
		pascal
		pasteur
		payne
		perlman
		pike
		poincare
		poitras
		proskuriakova
		ptolemy
		raman
		ramanujan
		ride
		montalcini
		ritchie
		rhodes
		robinson
		roentgen
		rosalind
		rubin
		saha
		sammet
		sanderson
		satoshi
		shamir
		shannon
		shaw
		shirley
		shockley
		shtern
		sinoussi
		snyder
		solomon
		spence
		stonebraker
		sutherland
		swanson
		swartz
		swirles
		taussig
		tereshkova
		tesla
		tharp
		thompson
		torvalds
		tu
		turing
		varahamihira
		vaughan
		visvesvaraya
		volhard
		villani
		wescoff
		wilbur
		wiles
		williams
		williamson
		wilson
		wing
		wozniak
		wright
		wu
		yalow
		yonath
		zhukovsky)'
    DEMYX_NAME_SUR_COUNT="${#DEMYX_NAME_SUR[@]}"
    DEMYX_NAME_SUR_RANDOM="$(((RANDOM % "$DEMYX_NAME_SUR_COUNT")+1))"
    echo "${DEMYX_NAME_SUR[$DEMYX_NAME_SUR_RANDOM]}"
}

demyx_name() {
    DEMYX_NAME_LEFT="$(demyx_name_adjectives)"
    DEMYX_NAME_RIGHT="$(demyx_name_sur)"
    DEMYX_NAME_ID="$(demyx util --id --raw)"
    echo "${DEMYX_NAME_LEFT}_${DEMYX_NAME_RIGHT}_${DEMYX_NAME_ID}"
}
