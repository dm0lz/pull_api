// const puppeteer = require("puppeteer-extra");
// const RecaptchaPlugin = require("puppeteer-extra-plugin-recaptcha");
// puppeteer.use(
//   RecaptchaPlugin({
//     provider: {
//       id: "2captcha",
//       token: "xxx",
//     },
//     visualFeedback: true,
//   })
// );
// const StealthPlugin = require("puppeteer-extra-plugin-stealth");
// puppeteer.use(StealthPlugin());
// const run_script = (positionOffset) => {
//   return {
//     next: document.querySelector("#pnnext")?.getAttribute("href"),
//     serp_url: document.location.href,
//     search_results: [
//       ...document.querySelectorAll("#search > div > div > div"),
//     ].map((article, index) => ({
//       site_name:
//         article
//           .querySelector(
//             "div > div > div > div > div > div > div > div > div > div > div > div > div > div > div > div > div > div > div"
//           )
//           ?.textContent?.trim() || "N/A",
//       url:
//         article
//           .querySelector(
//             "div > div > div > div > div > div > div > div > div > div > div > div > div > div > span > a"
//           )
//           ?.getAttribute("href") || "N/A",
//       title:
//         article
//           .querySelector(
//             "div > div > div > div > div > div > div > div > div > div > div > div > div > div > span > a > h3"
//           )
//           ?.textContent?.trim() || "N/A",
//       description:
//         article
//           .querySelectorAll(
//             "div > div > div > div > div > div > div > div > div > div > div"
//           )
//           [
//             article.querySelectorAll(
//               "div > div > div > div > div > div > div > div > div > div > div"
//             ).length - 1
//           ]?.textContent?.trim() || "N/A",
//       position: positionOffset + index + 1,
//     })),
//   };
// };
// (async () => {
//   const browser = await puppeteer.launch({
//     headless: false,
//     slowMo: 50,
//   });
//   const page = await browser.newPage();
//   await page.goto("https://www.google.com/");
//   await page.click("#L2AGLb");
//   await page.type("textarea", "arioz");
//   await page.keyboard.press("Enter");
//   await page.waitForSelector("iframe");
//   const { captchas, filtered, solutions, solved, error } =
//     await page.solveRecaptchas();
//   await page.waitForNavigation();
//   const results = [];
//   let positionOffset = 0;
//   while (true) {
//     const data = await page.evaluate(run_script, positionOffset);
//     results.push(data);
//     positionOffset += data.search_results.length;
//     if (!data.next || positionOffset / 10 >= 3) {
//       break;
//     }
//     await page.goto("https://www.google.com" + data.next);
//   }
//   console.log(JSON.stringify(results));
//   await browser.close();
// })();

// const { chromium } = require("playwright-extra");
// const stealth = require("puppeteer-extra-plugin-stealth")();
// chromium.use(stealth);
// const run_script = (positionOffset) => {
//   try {
//     return {
//       next: document.querySelector("a.next")?.getAttribute("href"),
//       serp_url: document.location.href,
//       search_results: [...document.querySelectorAll("div > ol > li")]
//         .slice(3)
//         .map((article, index) => ({
//           site_name:
//             article.querySelector("div > div > span")?.textContent?.trim() ||
//             "N/A",
//           url:
//             article.querySelector("div > div > h3 > a")?.getAttribute("href") ||
//             "N/A",
//           title:
//             article.querySelector("div > div > h3 > a")?.textContent?.trim() ||
//             "N/A",
//           description:
//             article.querySelector("div > div > p")?.textContent?.trim() ||
//             "N/A",
//           position: positionOffset + index + 1,
//         })),
//     };
//   } catch (error) {
//     console.log(error);
//   }
// };
// (async () => {
//   const browser = await chromium.launch({ headless: false });
//   const page = await browser.newPage();
//   await page.goto("https://search.yahoo.com/search?p=arioz");
//   await page.click(".accept-all");
//   await page.waitForSelector("div > ol > li", { timeout: 5000 });
//   const results = [];
//   let positionOffset = 0;
//   try {
//     do {
//       const data = await page.evaluate(run_script, positionOffset);
//       results.push(data);
//       positionOffset += data.search_results.length;
//       if (!data.next || positionOffset / 10 >= 6) {
//         break;
//       }
//       await page.goto(data.next);
//       await page.waitForSelector("div > ol > li", { timeout: 5000 });
//     } while (true);
//   } catch (e) {
//     console.log(e);
//   }
//   console.log(JSON.stringify(results));
//   await browser.close();
// })();

// const { chromium } = require("playwright-extra");
// const stealth = require("puppeteer-extra-plugin-stealth")();
// chromium.use(stealth);
// (async () => {
//   const browser = await chromium.launch({ headless: false });
//   const page = await browser.newPage();
//   await page.goto(
//     "https://www.linkedin.com/uas/login?session_redirect=https%3A%2F%2Fwww.linkedin.com%2Ffeed%2F"
//   );
//   await page.fill("input#username", "");
//   await page.fill("input#password", "");
//   const sign_in_button = await page.waitForSelector(
//     '[data-litms-control-urn="login-submit"]'
//   );
//   await sign_in_button.click();
//   // await page.fill('[role="combobox"]', "ruby on rails");
//   query = "ruby on rails";
//   await page.goto(
//     "https://www.linkedin.com/search/results/content/?keywords=" + query
//   );
//   await page.waitForSelector('[role="combobox"]');
//   // await page.keyboard.press("Enter");
//   let i = 0;
//   do {
//     await page.mouse.wheel(0, 1000);
//     await page.waitForTimeout(250);
//     i += 1;
//   } while (i < 3);
//   const list_items = await page.$$('ul[role="list"] > li');
//   for (const [index, list_item] of list_items.entries()) {
//     try {
//       const comment_button = await list_item.$(
//         ".social-actions-button.comment-button"
//       );
//       await comment_button.scrollIntoViewIfNeeded();
//       await comment_button.click();
//       const text_editor = await list_item.$(".ql-editor");
//       await text_editor.click();
//       await text_editor.fill(`Test comment #${index + 1}`);
//       const button = await page.waitForSelector(
//         "form > div > div > div > div > button"
//       );
//       const submit_button = await list_item.$(
//         "form > div > div > div > div > button"
//       );
//       await submit_button.click();
//       await page.waitForTimeout(2000);
//     } catch (error) {
//       console.log(error);
//     }
//   }
//   await browser.close();
// })();

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
  await page.fill("input#email", "");
  await page.fill("input#pass", "");
  const sign_in_button = await page.waitForSelector("button#loginbutton");
  await sign_in_button.click();
  await page.waitForSelector('input[role="combobox"]');
  query = "ruby";
  await page.goto("https://www.facebook.com/search/posts/?q=" + query);
  await page.waitForSelector('input[role="combobox"]');
  let i = 0;
  do {
    await page.mouse.wheel(0, 1000);
    await page.waitForTimeout(250);
    i += 1;
  } while (i < 3);
  const list_items = await page.$$('div[role="feed"] > div');
  for (const [index, list_item] of list_items.entries()) {
    try {
      const comment_button = await list_item.$(
        '[aria-label="Laissez un commentaire"]'
      );
      await comment_button.scrollIntoViewIfNeeded();
      await comment_button.click();
      const editable_content = await page.waitForSelector(
        '[contenteditable="true"]'
      );
      await editable_content.click();
      await editable_content.fill(`Test comment #${index + 1}`);
      const submit_button = await page.waitForSelector(
        'span > div[aria-label="Commenter"]'
      );
      await submit_button.click();
      const group_checkbox = await page.waitForSelector(
        '[name="agree-to-group-rules"]'
      );
      if (group_checkbox) {
        await group_checkbox.click();
        const group_submit = await page.waitForSelector(
          '[aria-label="Envoyer"]'
        );
        await group_submit.click();
      }
      await page.waitForTimeout(2000);
      const close_button = await page.waitForSelector(
        'div[aria-label="Fermer"]'
      );
      await close_button.click();
    } catch (error) {
      console.log(error);
    }
  }
  await browser.close();
})();
