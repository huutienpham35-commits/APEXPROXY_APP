import SwiftUI
import UIKit

private enum BodyProxyFeature: String, CaseIterable, Identifiable {
    case body = "Body"
    case chest = "Ngực"
    case drag = "Drag"
    case magic = "Magic"

    var id: String { rawValue }
    var filename: String {
        switch self {
        case .body: return "Body.cache_res"
        case .chest: return "Chest.cache_res"
        case .drag: return "Drag.cache_res"
        case .magic: return "Magic.cache_res"
        }
    }
    var icon: String {
        switch self {
        case .body: return "scope"
        case .chest: return "target"
        case .drag: return "arrow.up.right"
        case .magic: return "wand.and.stars"
        }
    }
    var tint: Color {
        switch self {
        case .body: return .orange
        case .chest: return .yellow
        case .drag: return .blue
        case .magic: return .purple
        }
    }
    var projectID: UUID {
        switch self {
        case .body: return UUID(uuidString: "8E7E9C1A-0B2C-4F16-9C3A-111111111111")!
        case .chest: return UUID(uuidString: "8E7E9C1A-0B2C-4F16-9C3A-222222222222")!
        case .drag: return UUID(uuidString: "8E7E9C1A-0B2C-4F16-9C3A-333333333333")!
        case .magic: return UUID(uuidString: "8E7E9C1A-0B2C-4F16-9C3A-444444444444")!
        }
    }
}

struct BodyProxyView: View {
    @State private var selectedApp: InstalledApp?
    @State private var apps: [InstalledApp] = []
    @State private var enabled: [BodyProxyFeature: Bool] = [:]
    @State private var busyFeature: BodyProxyFeature?
    @State private var message = "Đã sẵn sàng"
    @State private var showAppPicker = false

    private let relativePath = "Documents/contentcache/Compulsory/ios/gameassetbundles/cache_res.CfnFf59sr1SbsqQ6JqTKsEusjKs~3D"

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.035, green: 0.035, blue: 0.08), Color(red: 0.10, green: 0.055, blue: 0.17)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        header
                        targetCard
                        ForEach(BodyProxyFeature.allCases) { feature in
                            featureCard(feature)
                        }
                        statusCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showAppPicker) {
                AppTargetPicker(apps: apps, selectedApp: selectedApp) { app in
                    selectedApp = app
                    showAppPicker = false
                }
            }
            .task { refreshApps() }
        }
    }

    private var header: some View {
        VStack(spacing: 7) {
            Text("PROXY DELTA VIP")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text("FFMAX • FFTH")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }

    private var targetCard: some View {
        Button { showAppPicker = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "gamecontroller.fill")
                    .font(.title2)
                    .foregroundStyle(.cyan)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 3) {
                    Text("GAME MỤC TIÊU")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white.opacity(0.55))
                    Text(selectedApp?.displayName ?? "Chưa chọn FFMAX / FFTH")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.55))
            }
            .padding(15)
            .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.08)))
        }
        .buttonStyle(.plain)
    }

    private func featureCard(_ feature: BodyProxyFeature) -> some View {
        HStack(spacing: 13) {
            Image(systemName: feature.icon)
                .font(.title3.weight(.bold))
                .foregroundStyle(feature.tint)
                .frame(width: 44, height: 44)
                .background(feature.tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 3) {
                Text("Proxy \(feature.rawValue)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)
                Text("Thay cache_res khi bật")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.48))
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { enabled[feature] ?? false },
                set: { newValue in toggle(feature, enabled: newValue) }
            ))
            .labelsHidden()
            .tint(feature.tint)
            .disabled(busyFeature != nil || selectedApp == nil)
        }
        .padding(15)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(feature.tint.opacity(0.16)))
    }

    private var statusCard: some View {
        HStack(spacing: 10) {
            if busyFeature != nil {
                ProgressView().tint(.white)
            } else {
                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
            }
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
        }
        .padding(15)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
    }

    private func refreshApps() {
        var discovered = ContainerStore.installedAppsFromAPI()
        if discovered.isEmpty {
            discovered = ContainerStore.installedAppsFromMCM()
        }
        apps = discovered.filter { app in
            let name = app.displayName.lowercased()
            return name.contains("free fire") || name.contains("freefire") || name.contains("ffmax") || name.contains("ffth")
        }
        if selectedApp == nil { selectedApp = apps.first }
        message = selectedApp == nil ? "Chưa tìm thấy FFMAX / FFTH" : "Đã sẵn sàng"
    }

    private func toggle(_ feature: BodyProxyFeature, enabled newValue: Bool) {
        guard let target = selectedApp else {
            message = "Hãy chọn FFMAX hoặc FFTH trước"
            return
        }
        busyFeature = feature
        message = newValue ? "Đang áp dụng \(feature.rawValue)…" : "Đang khôi phục \(feature.rawValue)…"

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if newValue {
                    guard let url = Bundle.main.url(forResource: feature.filename.replacingOccurrences(of: ".cache_res", with: ""), withExtension: "cache_res", subdirectory: "BodyProxy") else {
                        throw PatchPackageError.applyFailed
                    }
                    let data = try Data(contentsOf: url)
                    let project = PatchProject(
                        id: feature.projectID,
                        name: "Proxy \(feature.rawValue)",
                        bundleIdentifiers: [target.bundleID],
                        rules: [PatchRule(
                            bundleID: target.bundleID,
                            relativePath: relativePath,
                            replacementFilename: feature.filename,
                            replacementData: data
                        )]
                    )
                    _ = try DevicePatchService.apply(project: project)
                } else if let receipt = DevicePatchService.latestReceipt(projectID: feature.projectID) {
                    try DevicePatchService.restore(receipt: receipt)
                }

                DispatchQueue.main.async {
                    enabled[feature] = newValue
                    busyFeature = nil
                    message = newValue ? "Proxy \(feature.rawValue) đã bật" : "Proxy \(feature.rawValue) đã tắt và khôi phục"
                }
            } catch {
                DispatchQueue.main.async {
                    busyFeature = nil
                    message = "Lỗi: \(error.localizedDescription)"
                }
            }
        }
    }
}

private struct AppTargetPicker: View {
    let apps: [InstalledApp]
    let selectedApp: InstalledApp?
    let onSelect: (InstalledApp) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(apps) { app in
                Button { onSelect(app) } label: {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                        VStack(alignment: .leading) {
                            Text(app.displayName)
                            Text(app.bundleID).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        if app == selectedApp { Image(systemName: "checkmark") }
                    }
                }
            }
            .navigationTitle("Chọn game")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Đóng") { dismiss() } }
            }
        }
    }
}
