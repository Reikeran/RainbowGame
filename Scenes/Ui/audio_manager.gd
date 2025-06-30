extends Node2D
var  bgmIsPlaying : bool = false

func PlayBgm():
	if bgmIsPlaying:
		$BGM.stop()
		bgmIsPlaying = false
	else:
		bgmIsPlaying = true
		$BGM.play()

func  PlayLoopSFX():
	$LoopMadeSFX.play()
	
func PlayCrashSFX():
	$CrashSFX.play()

func PlayBookthrow():
	$BookSFX.play()
