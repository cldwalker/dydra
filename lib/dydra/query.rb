module Dydra
  ##
  # Represents a Dydra.com SPARQL query.
  class Query < Resource
    SPEC = %r(^([^/\.]+)/([^/\.]+)/([^/\.]+)$) # /account/repository/query

    attr_reader :repository
    attr_reader :name

    ##
    # @param  [String, #to_s] repository_name
    # @param  [String, #to_s] name
    def initialize(repository_name, name)
      @repository = case repository_name
        when Repository then repository_name
        else Repository.new(*repository_name.to_s.split('/'))
      end
      @name = name.to_s
      super(Dydra::URL.join(path))
    end

    ##
    # Returns the path spec of this query.
    def path
      [repository.to_s, name].join('/')
    end

    ##
    # Returns a string representation of the query name.
    def to_s
      path
    end
  end # Query
end # Dydra
