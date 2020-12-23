# Build stage
FROM kullo/swiftbuild AS build

WORKDIR /app
COPY . .
RUN swift test && swift build -c release

# Output stage
FROM kullo/swiftbuild

RUN useradd -m chatserver
USER chatserver

WORKDIR /app
COPY Config Config
COPY --from=build /app/.build/x86_64-unknown-linux/release/Run Run

CMD ["/app/Run", "--env=production"]
