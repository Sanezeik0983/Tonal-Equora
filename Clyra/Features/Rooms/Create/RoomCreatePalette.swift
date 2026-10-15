import SwiftUI

struct RoomCreatePalette: View {
    let dismiss: () -> Void
    let create: (String, SoundLayout, Data?) -> Void

    @State private var name = ""
    @State private var layout: SoundLayout
    @State private var photoJPEGData: Data?
    @FocusState private var isNameFocused: Bool

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(
        initialLayout: SoundLayout = .stereo20,
        dismiss: @escaping () -> Void,
        create: @escaping (String, SoundLayout, Data?) -> Void
    ) {
        self.dismiss = dismiss
        self.create = create
        _layout = State(initialValue: initialLayout)
    }

    var body: some View {
        ZStack {
            RoomSoftBackdrop()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        nameField
                        photoPicker
                        layoutSelector
                        createButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 28)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
                .softScrollEdgeFade(top: 10, bottom: 16)
            }
        }
        .preferredColorScheme(.light)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("NEW ROOM")
                    .font(RoomSoftType.pixel(11.5, bold: false))
                    .tracking(0.8)
                    .foregroundStyle(RoomSoftPalette.orange)

                Text("Build a listening\nsetup")
                    .font(RoomSoftType.hero(30))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Name the room, add an optional photo, then choose its output.")
                    .font(RoomSoftType.body(13.5))
                    .foregroundStyle(RoomSoftPalette.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)
            closeButton
        }
    }

    private var closeButton: some View {
        Button {
            WavePulse.light()
            isNameFocused = false
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(width: 46, height: 46)
                .background {
                    Circle().fill(RoomSoftPalette.surface)
                }
                .overlay {
                    Circle()
                        .stroke(
                            RoomSoftPalette.lineStrong.opacity(0.72),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close room setup")
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ROOM NAME")
                .font(RoomSoftType.pixel(11, bold: false))
                .tracking(0.65)
                .foregroundStyle(RoomSoftPalette.ink)

            HStack(spacing: 10) {
                TextField(layout.defaultName, text: $name)
                    .font(RoomSoftType.body(18, medium: true))
                    .foregroundStyle(RoomSoftPalette.ink)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
                    .focused($isNameFocused)
                    .onSubmit {
                        isNameFocused = false
                    }

                if !name.isEmpty {
                    Button {
                        WavePulse.light()
                        name = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(RoomSoftPalette.inkFaint)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(RoomSoftPalette.surface)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isNameFocused
                            ? RoomSoftPalette.orange
                            : RoomSoftPalette.lineStrong.opacity(0.56),
                        lineWidth: isNameFocused ? 1.5 : 1
                    )
            }
        }
    }


    private var photoPicker: some View {
        RoomPhotoPickerPanel(
            imageData: photoJPEGData,
            presentation: .form,
            onPhotoSelected: { data in
                photoJPEGData = data
            },
            onRemovePhoto:
                photoJPEGData == nil
                    ? nil
                    : {
                        WavePulse.light()
                        photoJPEGData = nil
                    }
        )
    }

    private var layoutSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("OUTPUT TYPE")
                    .font(RoomSoftType.pixel(11, bold: false))
                    .tracking(0.65)
                    .foregroundStyle(RoomSoftPalette.ink)

                Spacer()

                Text(layout.shortLabel)
                    .font(RoomSoftType.dotted(20, weight: .semibold))
                    .foregroundStyle(RoomSoftPalette.orange)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(SoundLayout.allCases) { item in
                    layoutButton(item)
                }
            }
        }
    }

    private func layoutButton(_ item: SoundLayout) -> some View {
        let selected = layout == item

        return Button {
            WavePulse.selection()
            layout = item
        } label: {
            ZStack(alignment: .topLeading) {
                if selected {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(RoomSoftPalette.retroEdge)
                        .offset(x: 5, y: 5)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: item.symbol)
                            .font(.system(size: 19, weight: .medium))

                        Spacer()

                        Text(item.shortLabel)
                            .font(RoomSoftType.dotted(20, weight: .semibold))
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.rawValue)
                            .font(RoomSoftType.title(15.5))
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)

                        Text(item.description)
                            .font(RoomSoftType.body(11.5))
                            .foregroundStyle(RoomSoftPalette.inkSoft)
                            .lineLimit(2)
                    }
                }
                .foregroundStyle(RoomSoftPalette.ink)
                .padding(15)
                .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
                .background {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            selected
                                ? RoomSoftPalette.yellowSoft
                                : RoomSoftPalette.surface
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            selected
                                ? RoomSoftPalette.retroEdge
                                : RoomSoftPalette.lineStrong.opacity(0.52),
                            lineWidth: selected ? 1.2 : 1
                        )
                }
            }
            .padding(.trailing, selected ? 5 : 0)
            .padding(.bottom, selected ? 5 : 0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.rawValue)
        .accessibilityValue(selected ? "Selected" : item.description)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private var createButton: some View {
        Button {
            WavePulse.selection()
            isNameFocused = false
            create(
                cleanName,
                layout,
                photoJPEGData
            )
        } label: {
            HStack(spacing: 12) {
                Text("CREATE ROOM")
                    .font(RoomSoftType.pixel(12.5, bold: true))
                    .tracking(0.5)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(RoomSoftPalette.ink)
            .padding(.horizontal, 20)
            .frame(height: 60)
            .background {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(RoomSoftPalette.yellow)
            }
            .roomDoubleBorder(
                RoomSoftPalette.retroEdge,
                radius: 22,
                offset: 5
            )
        }
        .buttonStyle(.plain)
    }

    private var cleanName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? layout.defaultName : trimmed
    }
}
