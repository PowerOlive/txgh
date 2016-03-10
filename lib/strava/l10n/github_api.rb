require 'octokit'

module Strava
  module L10n
    class GitHubApi

      def initialize(login, oauth_token)
        @client = Octokit::Client.new(login: login, oauth_token: oauth_token)
      end

      def tags(repo)
        @client.tags(repo)
      end

      def tree(repo, sha)
        @client.tree(repo, sha, recursive: 1)
      end

      def blob(repo, sha)
        @client.blob(repo, sha)
      end

      def commit(repo, branch_name, path, content)
        blob = @client.create_blob repo, content
        branch = @client.ref repo, branch_name
        base_commit = @client.commit repo, branch[:object][:sha]
        tree = @client.create_tree repo,
                                   [{ path: path, mode: '100644', type: 'blob', sha: blob }],
                                   options = {base_tree: base_commit[:commit][:tree][:sha]}
        commit = @client.create_commit repo, "Updating translations for #{path}", tree[:sha],
                                       parents=branch[:object][:sha]
        @client.update_ref repo, branch_name, commit[:sha]
      end

      def pull(repo, head, base, title)
        @client.create_pull_request(repo, base, head, title)
      end

      def get_commit(repo, sha)
        @client.commit(repo, sha)
      end

    end
  end
end
