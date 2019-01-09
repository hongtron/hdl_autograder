module HdlAutograder
  class Config
    PROJECT_CONFIGS = YAML.load_file('./config/projects.yml')
  end
end
