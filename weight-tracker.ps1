$DOCKER_IMAGE = "megs-weight-tracker:latest"

function test-dockerimageexists {
  docker image inspect $DOCKER_IMAGE 2>&1 | out-null
  if ($LASTEXITCODE -ne 0) {
    write-host "Docker image does not exist: run .\setup.ps1"
    Pause
    exit 1
  }
}

$iniConfig = get-content .\config.ini | Select-Object -skip 1 | ConvertFrom-StringData

if (!$iniConfig.ClientID) {
  write-host "ClientID not set, unable to continue"
  Pause
  exit 1
}

if (!$iniConfig.ClientSecret) {
  write-host "ClientSecret not set, unable to continue"
  Pause
  exit 1
}

test-dockerimageexists
docker run --rm -it --mount type=bind,source="$(Get-Location)",destination=/workspace -e FITBIT_CLIENT_ID=$($iniConfig.ClientID) -e FITBIT_CLIENT_SECRET=$($iniConfig.ClientSecret) -e FITBIT_DATABASE=/workspace/fitbit.sqlite $DOCKER_IMAGE /workspace/Weight_Tracker.tsv
