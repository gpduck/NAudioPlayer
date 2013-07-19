if( !(Test-Path -Path Variable:NAudioPlayer)) {
	$Script:NAudioPlayer = $null
}

if( !(Test-Path -Path Variable:NAudioInputStream)) {
	$Script:NAudioInputStream = $null
}

function Get-OutputDevice {
	param(
		[ValidateSet("DirectSound","WaveOut")]
		[String]$Type,
		
		[string]$Name
	)
	switch ($Type) {
		"DirectSound" {
			$Devices = Get-NAudioCoreDirectSoundOutputDevice
		}
		"WaveOut" {
			$Devices = Get-NAudioCoreWaveOutputDevice
		}
		default {
			$Devices = Get-NAudioCoreDirectSoundOutputDevice
			$Devices += Get-NAudioCoreWaveOutputDevice
		}
	}
	if($Name) {
		$Devices | Where-Object {
			$_.Name -like $Name
		}
	} else {
		$Devices
	}
}
Export-ModuleMember -Function Get-OutputDevice

function Set-OutputDevice {
	param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="Lookup")]
		[ValidateSet("DirectSound","WaveOut")]
		[string]$Type,
		
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="Lookup")]
		[ValidateNotNullOrEmpty()]
		[string]$DeviceId,
		
		[Parameter(Mandatory=$true,ValueFromPipeline=$true,ParameterSetName="OutputDevice")]
		$InputObject
	)
	process {
		if($Script:NAudioPlayer) {
			#Cleanup
		}
		if($PSCmdlet.ParameterSetName -eq "Lookup") {
			$InputObject = Get-OutputDevice -Type $Type | ?{$_.DeviceId -eq $DeviceId}
			if(-not $InputObject) {
				Write-Error "Unable to locate output device $DeviceId of type $Type"
				return
			}
		}
		switch($InputObject.Type) {
			"DirectSound" {
				$Script:NAudioPlayer = New-NAudioCoreDirectSoundOutputDevice -Guid $InputObject.DeviceId
			}
			"WaveOut" {
				$Script:NAudioPlayer = New-NAudioCoreWaveOutputDevice -DeviceId $InputObject.DeviceId
			}
			default {
				Write-Error "Unknown output device type $($InputObject.Type)"
				return
			}
		}
	}
}
Export-ModuleMember -Function Set-OutputDevice

function Start-File {
	param(
		[Parameter(Mandatory=$true)]
		[IO.FileInfo]$Path
	)
	if($Script:NAudioPlayer) {
		#stop the current stream
		if($Script:NAudioPlayer.PlaybackState -eq [NAudio.Wave.PlaybackState]::Playing) {
			$Script:NAudioPlayer.Stop()
		}
		
		#if there is a stream open, close it before opening another one
		if($Script:NAudioInputStream) {
			Close-File
		}
		
		$Script:NAudioInputStream = New-NAudioCoreWaveInputStream -Path $Path
		
		$Script:NAudioPlayer.Init($Script:NAudioInputStream)
		
		$Script:NAudioPlayer.play()
	} else {
		Write-Error "NAudioPlayer must have an output device set using Set-NAudioOutputDevice"
	}
}
Export-ModuleMember -Function Start-File
New-Alias -Name Play-File -Value Start-File
Export-ModuleMember -Alias Play-File

function Resume-File {
	if($Script:NAudioPlayer) {
		if($Script:NAudioInputStream) {
			$Script:NAudioPlayer.play()
		} else {
			Write-Error "There is no file loaded, use Start-NAudioFile to load a file first"
		}
	} else {
		Write-Error "There is no output device set, use Set-NAudioOutputDevice first"
	}
}
Export-ModuleMember -Function Resume-File

function Stop-File {
	if($Script:NAudioPlayer) {
		$Script:NAudioPlayer.Stop()
		$Script:NAudioInputStream.position = 0
	}
}
Export-ModuleMember -Function Stop-File

function Suspend-File {
	if($Script:NAudioPlayer) {
		$Script:NAudioPlayer.Pause()
	}
}
Export-ModuleMember -Function Suspend-File
New-Alias -Name Pause-File -Value Suspend-File
Export-ModuleMember -Alias Pause-File

function Reset-File {
	if($Script:NAudioPlayer -and $Script:NAudioPlayer.PlaybackState -eq [NAudio.Wave.PlaybackState]::Playing) {
		Write-Error "Cannot seek file wile player is playing"
		return
	}
	if($Script:NAudioInputStream) {
		$Script:NAudioInputStream.position = 0
	}
}
Export-ModuleMember -Function Reset-File

function Close-File {
	if($Script:NAudioInputStream) {
		$Script:NAudioInputStream.Dispose()
		$Script:NAudioInputStream = $null
	}
}
Export-ModuleMember -Function Close-File

function Clear-Player {
	if($Script:NAudioPlayer) {
		$Script:NAudioPlayer.Dispose()
		$Script:NAudioPlayer = $Null
	}
}