import SwiftUI

struct RoomEditPalette: View {
    let setup: AcousticSetupProfile
    let canDelete: Bool
    let dismiss: () -> Void
    let save: (String, SoundLayout, Data?, Bool) -> Void
    let delete: () -> Void

    @State private var name: String
    @State private var layout: SoundLayout
    @State private var pendingPhotoJPEGData: Data?
    @State private var isExistingPhotoRemoved = false
    @State private var isDeleteConfirmationVisible = false
    @FocusState private var isNameFocused: Bool

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    init(
        setup: AcousticSetupProfile,
        canDelete: Bool,
        dismiss: @escaping () -> Void,
        save: @escaping (String, SoundLayout, Data?, Bool) -> Void,
        delete: @escaping () -> Void
    ) {
        self.setup = setup
        self.canDelete = canDelete
        self.dismiss = dismiss
        self.save = save
        self.delete = delete
        _name = State(initialValue: setup.name)
        _layout = State(initialValue: setup.layout)
    }

    var body: some View {
        ZStack {
            RoomSoftBackdrop()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        nameField
                        photoPicker
                        layoutSelector
                        saveButton
                        deleteButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 36)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
                .softScrollEdgeFade(top: 12, bottom: 18)
            }

            if isDeleteConfirmationVisible {
                deleteConfirmation
                    .zIndex(20)
            }
        }
        .preferredColorScheme(.light)
        .transition(
            .move(edge: .trailing)
                .combined(with: .opacity)
        )
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                backButton

                VStack(alignment: .leading, spacing: 7) {
                    Text("ROOM / EDIT")
                        .font(RoomSoftType.pixel(11.5, bold: false))
                        .tracking(0.8)
                        .foregroundStyle(RoomSoftPalette.orange)

                    Text("Room details")
                        .font(RoomSoftType.hero(30))
                        .foregroundStyle(RoomSoftPalette.ink)
                }

                Spacer(minLength: 8)

                Text(layout.shortLabel)
                    .font(RoomSoftType.dotted(20, weight: .semibold))
                    .foregroundStyle(RoomSoftPalette.orange)
                    .padding(.top, 4)
            }

            Text(
                "Rename the room, replace its photo or change the output. Calibration history stays attached."
            )
            .font(RoomSoftType.body(13.5))
            .foregroundStyle(RoomSoftPalette.inkSoft)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.leading, 60)
        }
    }

    private var backButton: some View {
        Button {
            WavePulse.light()
            isNameFocused = false
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(RoomSoftPalette.ink)
                .frame(width: 46, height: 46)
                .background {
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .fill(RoomSoftPalette.yellowSoft.opacity(0.82))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(
                            RoomSoftPalette.lineStrong.opacity(0.58),
                            lineWidth: 1
                        )
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back")
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ROOM NAME")
                .font(RoomSoftType.pixel(11, bold: false))
                .tracking(0.65)
                .foregroundStyle(RoomSoftPalette.ink)

            TextField(setup.layout.defaultName, text: $name)
                .font(RoomSoftType.body(18, medium: true))
                .foregroundStyle(RoomSoftPalette.ink)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .focused($isNameFocused)
                .onSubmit {
                    isNameFocused = false
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
            imageData: previewPhotoData,
            presentation: .form,
            onPhotoSelected: { data in
                pendingPhotoJPEGData = data
                isExistingPhotoRemoved = false
            },
            onRemovePhoto:
                previewPhotoData == nil
                    ? nil
                    : {
                        WavePulse.light()
                        pendingPhotoJPEGData = nil
                        isExistingPhotoRemoved = true
                    }
        )
    }

    private var previewPhotoData: Data? {
        if let pendingPhotoJPEGData {
            return pendingPhotoJPEGData
        }

        guard !isExistingPhotoRemoved,
              let photoFileName = setup.photoFileName
        else {
            return nil
        }

        return RoomPhotoStore.data(
            for: photoFileName
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

                    Text(item.rawValue)
                        .font(RoomSoftType.title(15.5))
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
                .foregroundStyle(RoomSoftPalette.ink)
                .padding(15)
                .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
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
    }

    private var saveButton: some View {
        Button {
            WavePulse.selection()
            isNameFocused = false
            save(
                cleanName,
                layout,
                pendingPhotoJPEGData,
                isExistingPhotoRemoved
            )
        } label: {
            HStack(spacing: 12) {
                Text("SAVE CHANGES")
                    .font(RoomSoftType.pixel(12.5, bold: true))
                    .tracking(0.5)

                Spacer()

                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .bold))
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

    private var deleteButton: some View {
        Button {
            guard canDelete else {
                return
            }

            WavePulse.light()
            isNameFocused = false

            withAnimation(.easeInOut(duration: 0.16)) {
                isDeleteConfirmationVisible = true
            }
        } label: {
            Text(
                canDelete
                    ? "DELETE ROOM"
                    : "KEEP AT LEAST ONE ROOM"
            )
            .font(RoomSoftType.pixel(11, bold: false))
            .tracking(0.65)
            .foregroundStyle(
                canDelete
                    ? RoomSoftPalette.coral
                    : RoomSoftPalette.inkFaint
            )
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .disabled(!canDelete)
    }

    private var deleteConfirmation: some View {
        ZStack {
            Color.black.opacity(0.30)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.16)) {
                        isDeleteConfirmationVisible = false
                    }
                }

            VStack(alignment: .leading, spacing: 16) {
                Text("DELETE ROOM")
                    .font(RoomSoftType.pixel(11, bold: false))
                    .tracking(0.7)
                    .foregroundStyle(RoomSoftPalette.coral)

                Text("Remove \(setup.name)?")
                    .font(RoomSoftType.hero(24))
                    .foregroundStyle(RoomSoftPalette.ink)

                Text(
                    "Its calibration sessions and Music Assist records will be removed from local storage."
                )
                .font(RoomSoftType.body(13))
                .foregroundStyle(RoomSoftPalette.inkSoft)
                .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Button {
                        WavePulse.light()

                        withAnimation(.easeInOut(duration: 0.16)) {
                            isDeleteConfirmationVisible = false
                        }
                    } label: {
                        Text("CANCEL")
                            .font(RoomSoftType.pixel(11, bold: false))
                            .foregroundStyle(RoomSoftPalette.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(RoomSoftPalette.surfaceMuted)
                            }
                    }
                    .buttonStyle(.plain)

                    Button {
                        WavePulse.selection()
                        delete()
                    } label: {
                        Text("DELETE")
                            .font(RoomSoftType.pixel(11, bold: true))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(RoomSoftPalette.coral)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
            .frame(maxWidth: 390)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(RoomSoftPalette.background)
            }
            .roomDoubleBorder(
                RoomSoftPalette.retroEdge,
                radius: 26,
                offset: 6
            )
            .padding(.horizontal, 24)
        }
    }

    private var cleanName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? setup.name : trimmed
    }
}
