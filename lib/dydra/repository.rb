module Dydra
  ##
  # Represents a Dydra.com RDF repository.
  class Repository < Resource
    SPEC = %r(^([^/]+)/([^/]+)$) # /account/repository

    ##
    # @param  [Hash{Symbol => Object}] options
    # @option options [String] :account_name (nil)
    # @yield  [repository]
    # @yieldparam [Repository] repository
    # @return [Enumerator]
    def self.each(options = {}, &block)
      if block_given?
        result = Dydra::Client.rpc.call('dydra.repository.list', options[:account_name] || '')
        result.each do |(account_name, repository_name)|
          block.call(Repository.new(account_name, repository_name))
        end
      end
      enum_for(:each, options)
    end

    ##
    # The account the repository belongs to.
    #
    # @return [Account]
    attr_reader :account

    ##
    # The machine-readable name of the repository.
    #
    # @return [String]
    attr_reader :name

    ##
    # The short description of the repository.
    #
    # @return [String]
    attr_reader :summary

    ##
    # The long description of the repository.
    #
    # @return [String]
    attr_reader :description

    ##
    # The time that the repository was first created.
    #
    # @return [DateTime]
    attr_reader :created

    ##
    # The time that the repository was last updated.
    #
    # @return [DateTime]
    attr_reader :updated

    [:summary, :description, :created, :updated].each do |property|
      class_eval(<<-EOS)
        def #{property}(); info['#{property}']; end
      EOS
    end

    ##
    # @param  [String, #to_s] account_name
    # @param  [String, #to_s] name
    def initialize(account_name, name)
      @account = case account_name
        when Account then account_name
        else Account.new(account_name.to_s)
      end
      @name = name.to_s
      if Dydra::URL.respond_to?(:'/')
        super(Dydra::URL / @account.name / @name)    # RDF.rb 0.3.0+
      else
        super(Dydra::URL.join(@account.name, @name)) # RDF.rb 0.2.x
      end
    end

    ##
    # Creates this repository on Dydra.com.
    #
    # @return [Process]
    def create!
      Process.new(Dydra::Client.rpc.call('dydra.repository.create', path))
    end

    ##
    # Destroys this repository from Dydra.com.
    #
    # @return [Process]
    def destroy!
      Process.new(Dydra::Client.rpc.call('dydra.repository.destroy', path))
    end

    ##
    # Deletes all data from this repository.
    #
    # @return [Process]
    def clear!
      Process.new(Dydra::Client.rpc.call('dydra.repository.clear', path))
    end

    ##
    # Imports data from a URL into this repository.
    #
    # @param  [String, #to_s] url
    # @return [Process]
    def import!(url)
      Process.new(Dydra::Client.rpc.call('dydra.repository.import', path, url.to_s))
    end

    ##
    # Returns the number of RDF statements in this repository.
    #
    # @return [Integer]
    def count
      Dydra::Client.rpc.call('dydra.repository.count', path)
    end

    ##
    # Queries this repository.
    #
    # @param  [String] query
    # @return [Process]
    def query(query)
      Process.new(Dydra::Client.rpc.call('dydra.repository.query', path, query.to_s))
    end

    ##
    # Returns a string representation of the repository name.
    #
    # @return [String]
    def to_s
      [account.name, name].join('/')
    end

    ##
    # @private
    # @return [Hash]
    def info
      Dydra::Client.rpc.call('dydra.repository.info', path)
    end
  end # Repository
end # Dydra