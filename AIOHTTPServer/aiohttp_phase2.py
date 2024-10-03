from aiohttp import web
import json

# CORS middleware function
async def cors_middleware(app, handler):
    async def middleware_handler(request):
        # Handle OPTIONS preflight request for CORS
        if request.method == "OPTIONS":
            return web.Response(status=200, headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type,Authorization"
            })

        # Handle the actual request
        response = await handler(request)
        # Add CORS headers to the response
        response.headers['Access-Control-Allow-Origin'] = '*'
        return response
    return middleware_handler

# Handler for fetching paginated items
async def handle_items(request):
    try:
        page = int(request.query.get('page', 1))
        page_size = int(request.query.get('page_size', 5))

        # Create a list of items (e.g., 100 items)
        all_items = [{"id": i, "name": f"Item {i}"} for i in range(1, 101)]

        # Get the total number of items
        total_items = len(all_items)

        # Get the items for the requested page
        start = (page - 1) * page_size
        end = start + page_size
        items = all_items[start:end]

        # Return the paginated items along with the total item count
        response_data = {
            "items": items,
            "total": total_items
        }

        if start >= total_items:
            return web.Response(status=404, text=json.dumps({'error': 'No more items'}), content_type='application/json')

        return web.Response(
            text=json.dumps(response_data),
            content_type='application/json'
        )
    except Exception as e:
        return web.Response(status=500, text=f'Error: {str(e)}')

# Create the app and add CORS middleware
app = web.Application(middlewares=[cors_middleware])

# Add routes
app.router.add_get('/items', handle_items)

if __name__ == '__main__':
    web.run_app(app, port=8080)

