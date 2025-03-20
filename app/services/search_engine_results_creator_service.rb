class SearchEngineResultsCreatorService < BaseService
  def call(query)
    results = DuckduckgoSerpFetcherService.new(pages_number: 10).call(query)
    results = results["search_results"]
    results.map do |result|
      SearchEngineResult.create!(
        query: query,
        site_name: result["site_name"],
        title: result["title"],
        url: result["url"],
        description: result["description"],
        position: result["position"]
      )
    end
  end
end
