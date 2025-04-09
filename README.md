# PullAPI - Web Scraping & AI Analysis API

A powerful API combining web scraping capabilities with AI-powered analysis. Built with Ruby on Rails, this API provides stealth web scraping, content analysis, and data extraction functionalities.

## Features

- 🔍 **Advanced Web Scraping**: Stealth-mode scraping with Playwright
- 🤖 **AI Integration**: Direct access to Hugging Face models and Deep Seek R1
- 🌐 **SERP Analysis**: Search results from 5 major search engines
- 📧 **Contact Discovery**: Email and domain extraction tools
- 🔒 **Security**: API token authentication and rate limiting
- 📊 **Usage Tracking**: Credit-based system with detailed monitoring

## Getting Started

### Prerequisites

- Ruby 3.2.0+
- Rails 7.0+
- PostgreSQL
- Redis
- Python 3.8+ (for AI integrations)
- Node.js 16+ (for Playwright)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/pullapi.git
cd pullapi
```

2. Install dependencies:

```bash
bundle install
yarn install
pip install -r requirements.txt
```

3. Set up environment variables:

```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Set up the database:

```bash
rails db:create db:migrate
```

5. Start the server:

```bash
rails server
```

## API Documentation

### Authentication

All API requests require an API token in the Authorization header:

```bash
Authorization: Bearer YOUR_API_TOKEN
```

### Rate Limiting

- Default: 5 requests per minute
- Pro: 20 requests per minute
- Enterprise: Custom limits

### Endpoints

#### 1. SERP API

```http
GET /api/v1/serp
```

Fetch search engine results from multiple providers.

Parameters:

- `search_engine` (string): google | duckduckgo | yahoo | bing | yandex
- `pages_number` (integer): Number of pages to fetch
- `query` (string): Search query
  Cost: 1 credit

#### 2. Hugging Face Inference

```http
POST /api/v1/hf_inference
```

Run inference using any Hugging Face model.

Parameters:

- `task` (string): summarization | text-generation | sentiment-analysis | etc.
- `model` (string): Hugging Face model name
- `input` (string): Input text
  Cost: 3 credits

#### 3. Web Page Scraping

```http
POST /api/v1/scrap_web_page
```

Scrape a single web page with custom JavaScript execution.

Parameters:

- `url` (string): Target URL
- `js_script` (string): Custom JavaScript to execute
  Cost: 1 credit

#### 4. Multiple Pages Scraping

```http
POST /api/v1/scrap_web_pages
```

Scrape multiple web pages simultaneously.

Parameters:

- `urls` (array): List of URLs
- `js_script` (string): Custom JavaScript to execute
  Cost: 1 credit per page

#### 5. Domain Scraping

```http
POST /api/v1/scrap_domain
```

Scrape an entire domain recursively.

Parameters:

- `domain` (string): Target domain
- `js_script` (string): Custom JavaScript to execute
  Cost: 2 credits

#### 6. Domain Lookup

```http
GET /api/v1/company_domain
```

Find domain from company name.

Parameters:

- `company` (string): Company name
  Cost: 2 credits

#### 7. Email Discovery

```http
GET /api/v1/domain_emails
```

Extract email addresses from a domain.

Parameters:

- `domain` (string): Target domain
  Cost: 2 credits

#### 8. Web Page Analysis

```http
POST /api/v1/analyze_web_page
```

Analyze web page content using Deep Seek R1.

Parameters:

- `url` (string): Target URL
- `prompt` (string): Analysis prompt
  Cost: 2 credits

#### 9. SERP Analysis

```http
POST /api/v1/analyze_serp
```

Analyze search results with custom prompts.

Parameters:

- `query` (string): Search query
- `prompt` (string): Analysis prompt
- `search_engine` (string): Search engine name
- `pages_number` (integer): Number of pages
  Cost: 2 credits

#### 10. List Hugging Face Models

```http
GET /api/v1/hf_models
```

Get available Hugging Face models.

Parameters:

- `task` (string, optional): Filter by task
- `limit` (integer, optional): Number of results
  Cost: 0 credits

## Pricing

- $0.001 per credit
- 2500 free credits upon signup
- Credits never expire
- Pay-as-you-go model

## Error Handling

The API uses standard HTTP response codes:

- 200: Success
- 400: Bad Request
- 401: Unauthorized
- 429: Too Many Requests
- 500: Server Error

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Support

For support, email support@pullapi.com or create an issue in the repository.
