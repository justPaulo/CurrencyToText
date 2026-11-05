import AppKit

guard CommandLine.arguments.count == 2 else {
    fputs("Usage: generate_app_icon.swift <iconset-directory>\n", stderr)
    exit(2)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let fileManager = FileManager.default
try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let iconSizes: [(name: String, pixels: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

func rect(_ x: CGFloat, _ top: CGFloat, _ width: CGFloat, _ height: CGFloat, in size: CGFloat) -> NSRect {
    NSRect(x: x, y: size - top - height, width: width, height: height)
}

func roundedRect(_ x: CGFloat, _ top: CGFloat, _ width: CGFloat, _ height: CGFloat, _ radius: CGFloat, in size: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect(x, top, width, height, in: size), xRadius: radius, yRadius: radius)
}

for icon in iconSizes {
    let size = CGFloat(icon.pixels)
    let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: icon.pixels,
        pixelsHigh: icon.pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)
    NSGraphicsContext.current?.imageInterpolation = .high

    let scale = size / 1024
    let transform = NSAffineTransform()
    transform.scale(by: scale)
    transform.concat()

    let background = roundedRect(0, 0, 1024, 1024, 224, in: 1024)
    NSGradient(colors: [
        NSColor(calibratedRed: 0.19, green: 0.24, blue: 0.72, alpha: 1),
        NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.39, alpha: 1)
    ])!.draw(in: background, angle: -45)

    let paper = roundedRect(318, 190, 500, 644, 78, in: 1024)
    let shadow = NSShadow()
    shadow.shadowColor = NSColor(calibratedWhite: 0.02, alpha: 0.26)
    shadow.shadowBlurRadius = 34
    shadow.shadowOffset = NSSize(width: 0, height: -18)
    NSGraphicsContext.saveGraphicsState()
    shadow.set()
    NSColor(calibratedWhite: 0.98, alpha: 1).setFill()
    paper.fill()
    NSGraphicsContext.restoreGraphicsState()

    NSColor(calibratedRed: 0.82, green: 0.87, blue: 1, alpha: 1).setFill()
    roundedRect(590, 292, 140, 20, 10, in: 1024).fill()

    let lineColor = NSColor(calibratedRed: 0.19, green: 0.25, blue: 0.52, alpha: 1)
    lineColor.setFill()
    roundedRect(535, 438, 198, 29, 14, in: 1024).fill()
    roundedRect(535, 500, 160, 29, 14, in: 1024).fill()
    NSColor(calibratedRed: 0.46, green: 0.53, blue: 0.78, alpha: 1).setFill()
    roundedRect(535, 562, 184, 29, 14, in: 1024).fill()
    roundedRect(535, 624, 128, 29, 14, in: 1024).fill()

    let coinRect = rect(124, 350, 384, 384, in: 1024)
    let coin = NSBezierPath(ovalIn: coinRect)
    NSGradient(colors: [
        NSColor(calibratedRed: 1, green: 0.86, blue: 0.43, alpha: 1),
        NSColor(calibratedRed: 0.97, green: 0.63, blue: 0.18, alpha: 1)
    ])!.draw(in: coin, angle: -45)
    NSColor(calibratedRed: 1, green: 0.94, blue: 0.7, alpha: 0.9).setStroke()
    coin.lineWidth = 12
    coin.stroke()

    let innerCoin = NSBezierPath(ovalIn: rect(151, 377, 330, 330, in: 1024))
    innerCoin.lineWidth = 5
    NSColor(calibratedRed: 0.72, green: 0.43, blue: 0.12, alpha: 0.55).setStroke()
    innerCoin.stroke()

    let currencyMark = "1.00" as NSString
    let font = NSFont.systemFont(ofSize: 142, weight: .bold)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(calibratedRed: 0.2, green: 0.19, blue: 0.42, alpha: 1)
    ]
    let markSize = currencyMark.size(withAttributes: attributes)
    currencyMark.draw(
        at: NSPoint(x: (1024 - markSize.width) / 2 - 190, y: (1024 - markSize.height) / 2 - 5),
        withAttributes: attributes
    )

    NSGraphicsContext.current?.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()

    let destination = outputDirectory.appendingPathComponent(icon.name)
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "CurrencyToTextIcon", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not encode \(icon.name)"])
    }
    try data.write(to: destination)
}
