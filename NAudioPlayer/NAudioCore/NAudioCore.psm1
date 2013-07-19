function Get-DirectSoundOutputDevice {
	param(
		$Name
	)
	$FixedProperties = @(
		@{n="Name"; e={$_.Description}},
		@{n="DeviceId"; e={$_.Guid}},
		@{n="Type"; e={"DirectSound"}}
	)
	[NAudio.Wave.DirectSoundOut]::Devices | Where-Object {
		if($Name) {
			$_.Description -like $Name
		} else {
			$true
		}
	} | Select-Object $FixedProperties | ForEach-Object {
		$_.PSObject.TypeNames.Insert(0,"NAudio.Posh.OutputDevice")
		$_.PSObject.TypeNames.Insert(0,"NAudio.Posh.DirectSoundOutputDevice")
		$_
	}
}

function Get-WaveOutputDevice {
	param(
		$Name
	)
	$FixedProperties = @(
		@{n="Name"; e={$_.ProductName}},
		@{n="DeviceId"; e={$DeviceId}},
		@{n="Type"; e={"WaveOut"}}
	)
	0..([NAudio.Wave.WaveOut]::DeviceCount - 1) | ForEach-Object {
		$DeviceId = $_
		[NAudio.Wave.WaveOut]::GetCapabilities($_) | Select $FixedProperties
	} | Where-Object {
		if($Name) {
			$_.Name -like $Name
		} else {
			$true
		}
	} | ForEach-Object {
		$_.PSObject.TypeNames.Insert(0, "NAudio.Posh.OutputDevice")
		$_.PSObject.TypeNames.Insert(0, "NAudio.Posh.WaveOutputDevice")
		$_
	}
}

function New-WaveOutputDevice {
	param(
		[Parameter(Mandatory=$False,ValueFromPipelineByPropertyName=$true)]
		[int]$DeviceId = 0,
		
		[int]$Latency = 300
	)
	process {
		$WaveOut = New-Object NAudio.Wave.WaveOut
		$WaveOut.DeviceNumber = $DeviceId
		$WaveOut.DesiredLatency = $Latency
		$WaveOut
	}
}

function New-DirectSoundOutputDevice {
	param(
		[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
		$DeviceId,

		[Int]$Latency = 300
	)
	process {
		New-Object NAudio.Wave.DirectSoundOut($Guid, $Latency)
	}
}

function New-WaveInputStream {
	param(
		[IO.FileInfo]$Path
	)
	switch -regex ($Path.Extension) {
		"\.aiff" {
			New-Object NAudio.Wave.AiffFileReader($Path.Fullname)
		}
		"\.mp3" {
			New-Object NAudio.Wave.Mp3FileReader($Path.Fullname)
		}
		"\.wav" {
			$Stream = New-Object NAudio.Wave.WaveFileReader($Path)
			if($Stream.WaveFormat.Encoding -ne [NAudio.Wave.WaveFormatEncoding]::PCM -and $Stream.WaveFormat.Encoding -ne [NAudio.Wave.WaveFormatEncoding]::IeeeFloat) {
				$Stream = [NAudio.Wave.WaveFormatConversionStream]::CreatePcmStream($Stream)
			}
			$Stream
		}
		default {
			Write-Error "Unknown audio file type ($($Path.Extension))"
		}
	}
}

function Close-WaveInputStream {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[NAudio.Wave.WaveStream]$Stream
	)
	process {
		$Stream.Dispose()
	}
}

function New-WaveChannel {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[NAudio.Wave.WaveStream]$Stream
	)
	process {
		New-Object NAudio.Wave.SampleProviders.SampleChannel($Stream, $True)
	}
}

function New-WaveVolumeSampleProvider {
	param(
		$Channel
	)
		New-Object NAudio.Wave.SampleProviders.VolumeSampleProvider($Channel)
}

function Set-WaveChannelVolume {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[ValidateNotNullOrEmpty()]
		[NAudio.Wave.SampleProviders.SampleChannel]$Channel,
		
		[int]$Volume
	)
	process {
		$Channel.Volume = $Volume
	}
}