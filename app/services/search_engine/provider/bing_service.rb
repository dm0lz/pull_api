class SearchEngine::Provider::BingService < BaseService
  def initialize(pages_number: 10, options: "{}")
    @pages_number = pages_number
    @options = options
  end
  def call(query)
    serps = RuntimeExecutor::NodeService.new.call(js_code(query))
    serps.map { |serp| serp["search_results"] }.flatten
  end

  private
  def js_code(query)
    <<-JS
      const { chromium } = require("playwright-extra");
      const stealth = require("puppeteer-extra-plugin-stealth")();
      chromium.use(stealth);
      const run_script = (positionOffset) => {
        return {
          next: [...document.querySelectorAll("main > ol > li > nav > ul > li")][[...document.querySelectorAll("main > ol > li > nav > ul > li")].length-1]?.querySelector("a")?.getAttribute("href"),
          serp_url: document.location.href,
          search_results: [...document.querySelectorAll("main > ol > li")].filter(li => li.getAttribute("role") === "presentation").map((article, index) => ({
            site_name: article.querySelector("div > a > div:nth-child(2) > div")?.textContent?.trim() || "N/A",
            url: article.querySelector("h2 > a")?.getAttribute("href") || "N/A",
            title: article.querySelector("h2")?.textContent?.trim() || "N/A",
            description: article.querySelector("p")?.textContent?.trim() || "N/A",
            position: positionOffset + index + 1
          }))
        };
      };
      (async () => {
        const browser = await chromium.launch(#{@options});
        const page = await browser.newPage();
        await page.goto("https://www.bing.com/search?q=#{query}");
        const results = [];
        let positionOffset = 0;
        while (true) {
          const data = await page.evaluate(run_script, positionOffset);
          results.push(data);
          positionOffset += data.search_results.length;
          if (!data.next || positionOffset / 10 >= #{@pages_number}) {
            break;
          }
          await page.goto("https://www.bing.com" + data.next);
        }
        console.log(JSON.stringify(results));
        await browser.close();
      })();
    JS
  end
end
