$DOCKER_IMAGE = "megs-weight-tracker:latest"

function test-dockerimageexists {
  if (!((get-process -Name "Docker Desktop" -ErrorAction SilentlyContinue) -or (get-process -Name "com.docker.backend" -ErrorAction SilentlyContinue))) {
    if ([System.IO.File]::Exists("C:\Program Files\Docker\Docker\Docker Desktop.exe")) {
      write-host "Docker starting"
      start-process -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe"
      $dockerStartAttempts = 0
      do {
        $dockerStartAttempts++
        start-sleep -Seconds 5
        docker info 2>&1 | out-null
      } until (($dockerStartAttempts -gt 5) -or ($LASTEXITCODE -eq 0))
    }
    Else {
      write-host "Docker not installed in default location, please install Docker or start Docker if not in default location"
      Pause
      exit 1
    }
  }
  docker image inspect $DOCKER_IMAGE 2>&1 | out-null
  if ($LASTEXITCODE -ne 0) {
    write-host "Docker image does not exist: run .\setup.ps1"
    Pause
    exit 1
  }
}

try {
  $iniConfig = get-content .\config.ini -ErrorAction Stop | Select-Object -skip 1 | ConvertFrom-StringData
}
catch {
  write-host "Config.ini not present, unable to continue, if running this from an IDE please make sure you are running this from the correct directory"
  Pause
  exit 1
}

if (!$iniConfig.ClientID) {
  write-host "ClientID not set, unable to continue"
  Pause
  exit 2
}

if (!$iniConfig.ClientSecret) {
  write-host "ClientSecret not set, unable to continue"
  Pause
  exit 3
}

test-dockerimageexists
docker run --rm -it --mount "type=bind,source=${pwd},destination=/workspace" -e "FITBIT_CLIENT_ID=$($iniConfig.ClientID)" -e "FITBIT_CLIENT_SECRET=$($iniConfig.ClientSecret)" -e "FITBIT_DATABASE=/workspace/fitbit.sqlite" $DOCKER_IMAGE "/workspace/Weight_Tracker.tsv"

get-content .\Weight_Tracker.tsv | Set-Clipboard