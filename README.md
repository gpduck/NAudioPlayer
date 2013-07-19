NAudioPlayer
============

Simple PowerShell audio player based on NAudio

------------

Copy to your modules directory, then use Import-Module NAudioPlayer to load it up.

------------

Use Get-NAudioOutputDevice to list all output devices.  Currently only WaveOut device types work:

  Get-NAudioOutputDevice -Type WaveOut

  Name                            DeviceId Type
  ----                            -------- ----
  Speakers (Realtek High Definiti        0 WaveOut
  Realtek Digital Output (Realtek        1 WaveOut
  Realtek HD Audio 2nd output (Re        2 WaveOut
  Realtek Digital Output(Optical)        3 WaveOut

You can use -Name with wildcards to select a specific device:

  Get-NAudioOutputDevice -Type WaveOut -Name *Speak*

  Name                            DeviceId Type
  ----                            -------- ----
  Speakers (Realtek High Definiti        0 WaveOut
  
Then use Set-NAudioOutputDevice to set the device:

  Get-NAudioOutputDevice -Type WaveOut -Name *Speak* | Set-NAudioOutputDevice
  
After a device is selected, use Play-NAudioFile to play a file:

  Play-NAudioFile -Path c:\path\to\some\file.mp3
  
Supported file formats are: .mp3, .wav, .aiff.

Use Stop-NAudioFile, Pause-NAudioFile, and Resume-NAudioFile to stop/pause/resume playback.

Use Stop-NAudioFile or Reset-NAudioFile to reset playback to the beginning.

Use Close-NAudioFile to release resources held by the file and Clear-NAudioPlayer to release the player.
