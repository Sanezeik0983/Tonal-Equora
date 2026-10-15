import SwiftUI
import UIKit

struct RoomPhotoCropEditor: View {
    let sourceImage: UIImage
    let cancel: () -> Void
    let apply: (Data) -> Void

    @State private var zoom: CGFloat = 1
    @State private var committedZoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var committedOffset: CGSize = .zero
    @State private var cropViewportSize: CGSize = .zero

    var body: some View {
        ZStack {
            RoomSoftBackdrop()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)

                Spacer(minLength: 22)

                cropViewportContainer
                    .padding(.horizontal, 16)

                Spacer(minLength: 24)

                controls(viewportSize: cropViewportSize)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .preferredColorScheme(.light)
    }

    private var cropViewportContainer: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .aspectRatio(
                RoomPhotoCropSpec.aspectRatio,
                contentMode: .fit
            )
            .overlay {
                GeometryReader { proxy in
                    cropViewport(size: proxy.size)
                        .onAppear {
                            updateCropViewportSize(proxy.size)
                        }
                        .onChange(of: proxy.size) { _, newSize in
                            updateCropViewportSize(newSize)
                        }
                }
            }
    }

    private func updateCropViewportSize(
        _ newSize: CGSize
    ) {
        guard newSize.width > 0,
              newSize.height > 0,
              cropViewportSize != newSize else {
            return
        }

        cropViewportSize = newSize
        offset = clampedOffset(
            offset,
            viewportSize: newSize,
            zoom: zoom
        )
        committedOffset = offset
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text("ROOM PHOTO")
                    .font(RoomSoftType.pixel(10.5, bold: true))
                    .tracking(0.72)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text("Frame the room")
                    .font(RoomSoftType.hero(29))
                    .foregroundStyle(RoomSoftPalette.ink)

                Text("Move and zoom the image. Everything inside the frame becomes the saved room photo.")
                    .font(RoomSoftType.body(13.5))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Button {
                WavePulse.light()
                cancel()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(width: 48, height: 48)
                    .background {
                        Circle()
                            .fill(RoomSoftPalette.surface)
                    }
                    .overlay {
                        Circle()
                            .strokeBorder(
                                RoomSoftPalette.lineStrong.opacity(0.66),
                                lineWidth: 1
                            )
                    }
            }
            .buttonStyle(.plain)
        }
    }

    private func cropViewport(size: CGSize) -> some View {
        ZStack {
            RoomSoftPalette.retroEdge

            Image(uiImage: sourceImage)
                .resizable()
                .frame(
                    width: renderedImageSize(
                        viewportSize: size,
                        zoom: zoom
                    ).width,
                    height: renderedImageSize(
                        viewportSize: size,
                        zoom: zoom
                    ).height
                )
                .offset(offset)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let proposed = CGSize(
                                width: committedOffset.width + value.translation.width,
                                height: committedOffset.height + value.translation.height
                            )

                            offset = clampedOffset(
                                proposed,
                                viewportSize: size,
                                zoom: zoom
                            )
                        }
                        .onEnded { _ in
                            offset = clampedOffset(
                                offset,
                                viewportSize: size,
                                zoom: zoom
                            )
                            committedOffset = offset
                        }
                )
                .simultaneousGesture(
                    MagnifyGesture(minimumScaleDelta: 0.005)
                        .onChanged { value in
                            let proposedZoom = min(
                                max(committedZoom * value.magnification, 1),
                                RoomPhotoCropSpec.maximumZoom
                            )

                            zoom = proposedZoom
                            offset = clampedOffset(
                                offset,
                                viewportSize: size,
                                zoom: proposedZoom
                            )
                        }
                        .onEnded { _ in
                            zoom = min(
                                max(zoom, 1),
                                RoomPhotoCropSpec.maximumZoom
                            )
                            committedZoom = zoom
                            offset = clampedOffset(
                                offset,
                                viewportSize: size,
                                zoom: zoom
                            )
                            committedOffset = offset
                        }
                )

            RoomPhotoCropGrid()
                .allowsHitTesting(false)

            VStack {
                HStack {
                    cropCorner(rotation: 0)
                    Spacer()
                    cropCorner(rotation: 90)
                }

                Spacer()

                HStack {
                    cropCorner(rotation: -90)
                    Spacer()
                    cropCorner(rotation: 180)
                }
            }
            .padding(10)
            .allowsHitTesting(false)

            VStack {
                Spacer()

                HStack(spacing: 7) {
                    Circle()
                        .fill(RoomSoftPalette.orange)
                        .frame(width: 6, height: 6)

                    Text("SAVED FRAME")
                        .font(RoomSoftType.pixel(8, bold: true))
                        .tracking(0.44)
                        .foregroundStyle(.white)

                    Spacer()

                    Text("\(Int((zoom * 100).rounded()))%")
                        .font(RoomSoftType.dotted(13, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 11)
            }
            .allowsHitTesting(false)
        }
        .frame(width: size.width, height: size.height)
        .clipShape(
            RoundedRectangle(
                cornerRadius: RoomPhotoCropSpec.cornerRadius,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: RoomPhotoCropSpec.cornerRadius,
                style: .continuous
            )
            .strokeBorder(
                RoomSoftPalette.orange,
                lineWidth: 1.4
            )
        }
        .roomDoubleBorder(
            RoomSoftPalette.retroEdge,
            radius: RoomPhotoCropSpec.cornerRadius,
            offset: 5
        )
    }

    private func controls(viewportSize: CGSize) -> some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CROP SCALE")
                        .font(RoomSoftType.pixel(9, bold: true))
                        .tracking(0.52)
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text("PINCH · DRAG · RESET")
                        .font(RoomSoftType.mono(8.5))
                        .tracking(0.06)
                        .foregroundStyle(RoomSoftPalette.inkSoft)
                }

                Spacer()

                Button {
                    WavePulse.light()

                    withAnimation(
                        .snappy(
                            duration: 0.28,
                            extraBounce: 0.02
                        )
                    ) {
                        zoom = 1
                        committedZoom = 1
                        offset = .zero
                        committedOffset = .zero
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 10, weight: .bold))

                        Text("RESET")
                            .font(RoomSoftType.pixel(8.5, bold: true))
                            .tracking(0.38)
                    }
                    .foregroundStyle(RoomSoftPalette.ink)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background {
                        RoundedRectangle(
                            cornerRadius: 13,
                            style: .continuous
                        )
                        .fill(RoomSoftPalette.surfaceWarm)
                    }
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: 13,
                            style: .continuous
                        )
                        .strokeBorder(
                            RoomSoftPalette.lineStrong.opacity(0.52),
                            lineWidth: 1
                        )
                    }
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                Button {
                    WavePulse.light()
                    cancel()
                } label: {
                    Text("CANCEL")
                        .font(RoomSoftType.pixel(10, bold: true))
                        .tracking(0.46)
                        .foregroundStyle(RoomSoftPalette.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background {
                            RoundedRectangle(
                                cornerRadius: 18,
                                style: .continuous
                            )
                            .fill(RoomSoftPalette.surface)
                        }
                        .overlay {
                            RoundedRectangle(
                                cornerRadius: 18,
                                style: .continuous
                            )
                            .strokeBorder(
                                RoomSoftPalette.lineStrong.opacity(0.54),
                                lineWidth: 1
                            )
                        }
                }
                .buttonStyle(.plain)

                Button {
                    guard viewportSize.width > 0,
                          viewportSize.height > 0,
                          let data = RoomPhotoImageProcessor.croppedJPEGData(
                            from: sourceImage,
                            viewportSize: viewportSize,
                            zoom: zoom,
                            offset: offset
                          ) else {
                        return
                    }

                    WavePulse.selection()
                    apply(data)
                } label: {
                    HStack(spacing: 9) {
                        Text("APPLY CROP")
                            .font(RoomSoftType.pixel(10, bold: true))
                            .tracking(0.46)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(RoomSoftPalette.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background {
                        RoundedRectangle(
                            cornerRadius: 18,
                            style: .continuous
                        )
                        .fill(RoomSoftPalette.yellow)
                    }
                    .roomDoubleBorder(
                        RoomSoftPalette.retroEdge,
                        radius: 18,
                        offset: 4
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func cropCorner(rotation: Double) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 14))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 14, y: 0))
        }
        .stroke(
            Color.white,
            style: StrokeStyle(
                lineWidth: 2,
                lineCap: .round,
                lineJoin: .round
            )
        )
        .frame(width: 14, height: 14)
        .rotationEffect(.degrees(rotation))
    }

    private func renderedImageSize(
        viewportSize: CGSize,
        zoom: CGFloat
    ) -> CGSize {
        let scale = RoomPhotoImageProcessor.fillScale(
            imageSize: sourceImage.size,
            viewportSize: viewportSize
        ) * zoom

        return CGSize(
            width: sourceImage.size.width * scale,
            height: sourceImage.size.height * scale
        )
    }

    private func clampedOffset(
        _ proposed: CGSize,
        viewportSize: CGSize,
        zoom: CGFloat
    ) -> CGSize {
        let rendered = renderedImageSize(
            viewportSize: viewportSize,
            zoom: zoom
        )

        let horizontalLimit = max(
            (rendered.width - viewportSize.width) * 0.5,
            0
        )
        let verticalLimit = max(
            (rendered.height - viewportSize.height) * 0.5,
            0
        )

        return CGSize(
            width: min(max(proposed.width, -horizontalLimit), horizontalLimit),
            height: min(max(proposed.height, -verticalLimit), verticalLimit)
        )
    }
}
