class Social::Facebook::PostsReplierService < BaseService
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
        const browser = await chromium.launch({ headless: false });
        const page = await browser.newPage();
        await page.goto("https://www.facebook.com/login.php");
        await page.evaluate(() => {
          document
            .querySelectorAll('[aria-label="Refuser les cookies optionnels"]')[0]
            .click();
        });
        await page.fill("input#email", "#{Rails.application.credentials[:facebook_email]}");
        await page.fill("input#pass", "#{Rails.application.credentials[:facebook_password]}");
        const sign_in_button = await page.waitForSelector("button#loginbutton");
        await sign_in_button.click();
        await page.waitForSelector('input[role="combobox"]');
        query = "ruby";
        await page.goto("https://www.facebook.com/search/posts/?q=#{@query}");
        await page.waitForSelector('input[role="combobox"]');
        let i = 0;
        do {
          await page.mouse.wheel(0, 1000);
          await page.waitForTimeout(1000);
          i += 1;
        } while (i < 3);
        const list_items = await page.$$('div[role="feed"] > div');
        for (const [index, list_item] of list_items.entries()) {
          try {
            const comment_button = await list_item.$(
              '[aria-label="Laissez un commentaire"]'
            );
            if (comment_button) {
              await comment_button.scrollIntoViewIfNeeded();
              await comment_button.click();
              const editable_content = await page.waitForSelector(
                '[contenteditable="true"]'
              );
              await editable_content.click();
              await editable_content.fill("#{@payload}");
              const submit_button = await page.waitForSelector(
                'span > div[aria-label="Commenter"]'
              );
              await submit_button.click();
              const group_checkbox = await page.$('[name="agree-to-group-rules"]');
              if (group_checkbox) {
                await group_checkbox.click();
                const group_submit = await page.waitForSelector(
                  '[aria-label="Envoyer"]'
                );
                await group_submit.click();
              }
              await page.waitForTimeout(2000);
              const close_button = await page.$(
                'div[aria-label="Fermer"]'
              );
              if (close_button) {
                await close_button.click();
              }
            }
          } catch (error) {
            console.log(error);
          }
        }
        await browser.close();
      })();
    JS
  end
end
