job "restic" {
  datacenters = ["hydra"]
  type        = "batch"

  periodic {
    cron             = "0 3 * * *"
    time_zone        = "Asia/Kolkata"
    prohibit_overlap = true
  }
  ...
  task "backup" {
	  driver = "raw_exec"

	  config {
		# Since `/data` is owned by `root`, restic needs to be spawned as `root`. 

		# `raw_exec` spawns the process with which `nomad` client is running (`root` i.e.).
		command = "$${NOMAD_TASK_DIR}/restic_backup.sh"
	  }
  }
  ...
}