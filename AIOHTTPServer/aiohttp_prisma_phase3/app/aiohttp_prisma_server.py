import json
from aiohttp import web
from prisma import Prisma

# Custom CORS middleware
async def cors_middleware(app, handler):
    async def middleware_handler(request):
        # Handle OPTIONS preflight request for CORS
        if request.method == "OPTIONS":
            return web.Response(status=200, headers={
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type, Authorization"
            })

        # Handle the actual request and add CORS headers to the response
        response = await handler(request)
        response.headers['Access-Control-Allow-Origin'] = '*'
        return response
    return middleware_handler

async def handle_items(request):
    try:
        # Connect to Prisma ORM
        prisma = Prisma()
        await prisma.connect()

        # Fetch all items from the database (no pagination)
        items = await prisma.item.find_many()

        # Disconnect Prisma
        await prisma.disconnect()

        # Format the items into a JSON response
        items_list = [{"id": item.id, "name": item.name} for item in items]
        return web.json_response({"items": items_list})

    except Exception as e:
        return web.json_response({"error": str(e)}, status=500)

# Initialize aiohttp application
app = web.Application()

# Add custom CORS middleware
app.middlewares.append(cors_middleware)

# Add route for handling items
app.router.add_get('/items', handle_items)

if __name__ == '__main__':
    web.run_app(app, port=8080)

