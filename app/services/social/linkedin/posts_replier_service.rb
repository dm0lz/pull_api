class Social::Linkedin::PostsReplierService < BaseService
  def initialize(query, payload, options = "{headless: false}")
    @query = query
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
        await page.goto("https://www.linkedin.com/uas/login");
        await page.fill("input#username", "#{Rails.application.credentials[:linkedin_email]}");
        await page.fill("input#password", "#{Rails.application.credentials[:linkedin_password]}");
        const sign_in_button = await page.waitForSelector(
          '[data-litms-control-urn="login-submit"]'
        );
        await sign_in_button.click();
        await page.goto(
          "https://www.linkedin.com/search/results/content/?keywords=#{@query}"
        );
        await page.waitForSelector('[role="combobox"]');
        let i = 0;
        do {
          await page.mouse.wheel(0, 1000);
          await page.waitForTimeout(250);
          i += 1;
        } while (i < 50);
        const list_items = await page.$$('ul[role="list"] > li');
        for (const [index, list_item] of list_items.entries()) {
          try {
            const comment_button = await list_item.$(
              ".social-actions-button.comment-button"
            );
            await comment_button.scrollIntoViewIfNeeded();
            await comment_button.click();
            const text_editor = await list_item.$(".ql-editor");
            await text_editor.click();
            await text_editor.fill("#{@payload}");
            const button = await page.waitForSelector(
              "form > div > div > div > div > button"
            );
            const submit_button = await list_item.$("form > div > div > div > div > button");
            await submit_button.click();
            await page.waitForTimeout(2000);
          } catch (error) {
            console.log(error);
          }
        }
        await browser.close();
      })();
    JS
  end
end
