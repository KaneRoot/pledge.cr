class Dir
  # Creates a new directory at the given path, including any non-existing
  # intermediate directories. The linux-style permission mode can be specified,
  # with a default of 777 (0o777).
  #
  # WARNING: this is a rewrite of the original `mkdir_p` to prevent
  # `unveil` from crashing the application. Once `unveil` has been
  # invoked, the application cannot know whether or not some path
  # actually exists unless it has been enabled via `unveil`. The original
  # `mkdir_p` started from the shortest path (such as `/`) then went
  # for the longest (`/some/` then `/some/random/` then `/some/random/path`).
  #
  # This version starts from the longest to the shortest, which enables
  # to use `mkdir_p` without `unveil`-ing a whole directory tree starting
  # from root (`/`, `/some`, `/some/random`, `/some/random/path`).
  def self.mkdir_p(path : Path | String, mode : Int32 = 0o777) : Nil
    return if Dir.exists?(path)

    path = Path.new path
    parents = [] of Path

    current_path = path.parent
    # From the longest to the shortest path.
    #   /some/random/path
    #   /some/random
    #   /some
    path.parents.reverse.each do |parent|
      break if Dir.exists? parent
      parents << parent
    end

    parents.each do |parent|
      mkdir(parent, mode)
    end

    mkdir(path, mode) unless Dir.exists?(path)
  end
end
