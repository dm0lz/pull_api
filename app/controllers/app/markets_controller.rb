module App
  class MarketsController < ApplicationController
    def index
      @markets = Market.all
    end
  end
end
