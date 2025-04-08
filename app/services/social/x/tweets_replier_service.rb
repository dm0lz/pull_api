class Social::X::TweetsReplierService < BaseService
  def initialize(search, payload, options = "{headless: false}")
    @search = search
    @payload = payload
    @options = options.gsub("\\", "")
  end

  def call
    puts js_code
    RuntimeExecutor::NodeService.new.call(js_code)
  end

  private
  def js_code
    <<-JS
      const { chromium } = require("playwright-extra");
      const stealth = require("puppeteer-extra-plugin-stealth")();
      chromium.use(stealth);
      (async () => {
        const browser = await chromium.launch(#{@options});
        const page = await browser.newPage();
        await page.goto("https://twitter.com/i/flow/login");
        await page.fill("input[name='text']", "#{Rails.application.credentials[:x_username]}");
        await page.keyboard.press("Enter");
        await page.waitForSelector("input[name='password']");
        await page.fill("input[name='password']", "#{Rails.application.credentials[:x_password]}");
        await page.keyboard.press("Enter");
        await page.waitForSelector('[role="combobox"]');
        await page.fill('[role="combobox"]', "#{@search}");
        await page.keyboard.press("Enter");
        await page.waitForTimeout(2000);
        let i = 0;
        do {
          await page.mouse.wheel(0, 1000);
          await page.waitForTimeout(250);
          i += 1;
        } while (i < 5);
        const links = await page.evaluate(() => {
          return [
            ...new Set(
              Array.from(
                document.querySelectorAll('article a[href*="/status/"]')
              ).map(
                (a) =>
                  "https://twitter.com" +
                  a.getAttribute("href").split("/status/")[0] +
                  "/status/" +
                  a.getAttribute("href").split("/status/")[1].split("/")[0]
              )
            ),
          ];
        });
        for (const link of links) {
          try {
            await page.goto(link);
            const textArea = await page.waitForSelector('[data-contents="true"]');
            await textArea.click();
            await textArea.fill("#{@payload}");
            const tweetButton = await page.waitForSelector(
              '[data-testid="tweetButtonInline"]'
            );
            await tweetButton.click();
          } catch (error) {
            console.log(error);
          }
        }
        console.log(links);
        await browser.close();
      })();
    JS
  end
end
