#!/usr/bin/env bash

timerEndNotificationSound='/usr/share/sounds/sound-icons/pisk-up.wav'
timerEndNotificationIcon='/usr/share/icons/Humanity/status/128/dialog-information.svg'


usage() {
	cat <<-EOF
	Run a timer and play sound + notify at the end

	options:
	  -h                show this [h]elp and exit
	  -t <duration>     start [t]imer for '<duration>', specified using 'sleep' syntax
	  -T                [T]est sound + notification
	EOF
	}


testSoundAndNotification() {
	echo "'test' mode"
	notifyTimerEnded
	}


playSound() {
	local soundToPlay=$1
	aplay -q "$soundToPlay"
	}


notifyTimerEnded() {
	# I've not found how to specify which monitor to display the notification on.
	# So far, looks like it appears on the last monitor I clicked in.
	notify-send --expire-time=5000 'TIME OUT !' -i "$timerEndNotificationIcon"
	playSound "$timerEndNotificationSound"
	}


emergencyExit() {
	echo -e '\n\t/!\ Emergency exit\n'
	exit 0
	}


makeDurationHumanReadable() {
	local duration=$1
	awk '
		/^[0-9]+$/	{ if($0 < 2) print $0 " second"; else print $0 " seconds"; }
		/^[0-9]+[ms]$/	{
			number=strtonum($0)
			unit=gensub(/^[0-9]+([ms])/, "\\1", "g")

			switch (unit) {
				case /m/:
					longUnit="minute"
					break
				case /s/:
					longUnit="second"
					break
				}
			 if(number > 1) print number" "longUnit"s"; else print number" "longUnit;
			 }
		' <<< "$duration"
	}


checkDuration() {
	local givenDuration=$1
	[[ ! "$givenDuration" =~ ^[0-9]+[ms]?$ ]] && {
		echo "'$givenDuration' doesn't look like a valid duration."
		usage
		exit 1
		}
	}


main() {
	trap emergencyExit SIGINT	# on CTRL-c
	while getopts ':ht:T' opt; do
		case "$opt" in
			t)	# the actual timer
				duration="${OPTARG}"
				checkDuration "$duration"
				echo "Timer started for $(makeDurationHumanReadable $duration)"
				sleep "$duration"
				notifyTimerEnded
				;;
			h)	# help
				usage
				exit 0
				;;
			T)	# test mode
				testSoundAndNotification
				exit 0
				;;
			:)	echo "Value expected for option '-$OPTARG'"; usage; exit 1 ;;
			\?)	echo "Invalid option: '-$OPTARG'"; usage; exit 1 ;;
		esac
	done
	}


main "$@"
