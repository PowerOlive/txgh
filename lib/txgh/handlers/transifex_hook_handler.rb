require 'logger'

module Txgh
  module Handlers
    class TransifexHookHandler
      attr_reader :project, :resource, :language, :logger

      def initialize(options = {})
        @project = options.fetch(:project)
        @resource = options.fetch(:resource)
        @language = options.fetch(:language)
        @logger = options.fetch(:logger) { Logger.new(STDOUT) }
      end

      def execute
        transifex_project = Txgh::TransifexProject.new(project)
        tx_resource = transifex_project.resource(resource)

        logger.info(resource)

        # Do not update the source
        unless language == tx_resource.source_lang
          logger.info('request language matches resource')

          translation = transifex_project.api.download(tx_resource, language)

          if tx_resource.lang_map(language) != language
            logger.info('request language is in lang_map and is not in request')
            translation_path = tx_resource.translation_path(tx_resource.lang_map(language))
          else
            logger.info('request language is in lang_map and is in request or is nil')
            translation_path = tx_resource.translation_path(transifex_project.lang_map(language))
          end

          github_branch = transifex_project.github_repo.config.fetch('branch', 'master')
          github_branch = github_branch.include?("tags/") ? github_branch : "heads/#{github_branch}"

          logger.info("make github commit for branch: #{github_branch}")

          transifex_project.github_repo.api.commit(
            transifex_project.github_repo.name, github_branch, translation_path, translation
          )
        end
      end

    end
  end
end