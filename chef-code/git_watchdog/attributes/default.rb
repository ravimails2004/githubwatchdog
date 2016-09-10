default["watchdog"]= {
	"startup" => {
		"poll_interval" => 60,
		"type" => "simple",
		"user" => "watchdog",
		"ExecStart" => "/usr/bin/watchdog.sh",
                "Restart_behaviour" => "on-abort"
		},
	"config_yaml_params" => {
		"logging_path" => "/home/watchdog/git_watchdog.log",
		"contributors_local_file" => "contributors.json",
		"contributors_api" => "https://api.github.com/repos/mitalikhare/study/contributors"
		
       },
	"twitter" => {
		"APP_KEY" => "AAAAAAAAAAAAAAAAAAAAAAAAAAA",
		"APP_SECRET" => "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
		"OAUTH_TOKEN" => "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
		"OAUTH_TOKEN_SECRET" => "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
          }
	}
