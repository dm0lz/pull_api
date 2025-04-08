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
        // await page.waitForSelector('input[role="combobox"]');
        let i = 0;
        let comment_buttons;
        do {
          // await page.waitForSelector('[aria-label="Laissez un commentaire"]', { timeout: 5000 });
          comment_buttons = await page.$$('[aria-label="Laissez un commentaire"]');
          while (comment_buttons.length === 0) {
            await page.mouse.wheel(0, 1000);
            comment_buttons = await page.$$('[aria-label="Laissez un commentaire"]');
          };
          // await page.evaluate(async() => {
          //   const comment_buttonz = document.querySelectorAll('[aria-label="Laissez un commentaire"]');
          //   for (const comment_button of comment_buttonz) {
          //     comment_button.click();
          //     await new Promise(r => setTimeout(r, 2000));
          //     const editable_content = document.querySelector('div[role="textbox"][contenteditable="true"]');
          //     if (editable_content) {
          //       editable_content.focus();
          //       if (document.execCommand('insertText', false, "#{@payload}")) {
          //         await new Promise(r => setTimeout(r, 2000));
          //         const submit_button = document.querySelector('div[aria-label="Commenter"]');
          //         if (submit_button) {
          //           submit_button.click();
          //         }
          //       }
          //     }
          //     const close_button = document.querySelector(
          //       'div[aria-label="Fermer"]'
          //     );
          //     if (close_button) {
          //       close_button.click();
          //     }
          //   }
          // });
          for (const comment_button of comment_buttons) {
            await comment_button.scrollIntoViewIfNeeded();
            await comment_button.click();
            const editable_content = await page.waitForSelector('div[role="textbox"][contenteditable="true"]', { timeout: 5000 });
            await editable_content.click();
            await editable_content.fill("#{@payload}");
            const submit_button = await page.waitForSelector('div[aria-label="Commenter"]', { timeout: 5000 });
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
          await page.mouse.wheel(0, 1000);
          await page.waitForTimeout(1000);
          await page.mouse.wheel(0, 1000);
          await page.waitForTimeout(1000);
          await page.mouse.wheel(0, 1000);
          await page.waitForTimeout(1000);
          i += 1;
        } while (i < 10);
        await browser.close();
      })();
    JS
  end
end
