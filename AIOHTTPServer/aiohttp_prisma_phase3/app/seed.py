from prisma import Prisma

async def seed():
    prisma = Prisma()
    await prisma.connect()

    # Insert additional items (up to 100)
    for i in range(1, 101):
        await prisma.item.create(
            data={
                "name": f"Item {i}"
            }
        )

    await prisma.disconnect()

if __name__ == '__main__':
    import asyncio
    asyncio.run(seed())

