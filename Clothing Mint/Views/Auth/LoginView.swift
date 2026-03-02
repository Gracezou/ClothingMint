//
//  LoginView.swift
//  Clothing Mint
//
//  登录页面，邮箱密码表单 + 验证
//

import SwiftUI

/// 登录页面
struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel = AuthViewModel()
    @State private var navigateToSignUp = false

    /// 邮箱输入框是否聚焦
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView {
                    VStack(spacing: 28) {
                        Spacer().frame(height: 40)

                        // 顶部标识
                        headerSection

                        // 登录表单
                        formSection

                        // 忘记密码
                        forgotPasswordLink

                        // 登录按钮
                        loginButton

                        // 注册入口
                        signUpLink

                        Spacer()
                    }
                    .padding(.horizontal, 32)
                }
            }
            .navigationDestination(isPresented: $navigateToSignUp) {
                SignupView()
            }
            .toast(isPresented: $viewModel.showToast, type: viewModel.toastType, message: viewModel.toastMessage)
            .onTapGesture { focusedField = nil }
        }
    }

    // MARK: - 子视图

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "tshirt.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white)

            Text("Clothing Mint")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("登录您的账号")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            // 邮箱
            VStack(alignment: .leading, spacing: 6) {
                InputField(
                    icon: "envelope.fill",
                    placeholder: "邮箱地址",
                    text: $viewModel.email,
                    keyboardType: .emailAddress
                )
                .focused($focusedField, equals: .email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .onSubmit { focusedField = .password }

                if let error = viewModel.emailError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.9))
                        .padding(.leading, 4)
                }
            }

            // 密码
            VStack(alignment: .leading, spacing: 6) {
                SecureInputField(
                    icon: "lock.fill",
                    placeholder: "密码",
                    text: $viewModel.password
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .onSubmit { Task { await performLogin() } }

                if let error = viewModel.passwordError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.9))
                        .padding(.leading, 4)
                }
            }
        }
    }

    private var loginButton: some View {
        Button {
            Task { await performLogin() }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color.mintPrimary)
                } else {
                    Text("登录")
                        .font(.headline)
                }
            }
            .foregroundStyle(Color.mintPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Capsule()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            )
        }
        .disabled(viewModel.isLoading || !viewModel.isLoginFormValid)
        .opacity(viewModel.isLoginFormValid ? 1 : 0.6)
    }

    private var forgotPasswordLink: some View {
        HStack {
            Spacer()
            Button {
                Task { await viewModel.resetPassword() }
            } label: {
                Text("忘记密码？")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .disabled(viewModel.isLoading)
        }
    }

    private var signUpLink: some View {
        Button {
            navigateToSignUp = true
        } label: {
            HStack(spacing: 4) {
                Text("还没有账号？")
                    .foregroundStyle(.white.opacity(0.7))
                Text("立即注册")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .font(.subheadline)
        }
    }

    // MARK: - 操作

    private func performLogin() async {
        focusedField = nil
        let success = await viewModel.login()
        if success {
            if let userId = await AuthService().getCurrentUserId() {
                appState.currentUserId = userId
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                appState.isAuthenticated = true
            }
        }
    }
}

// MARK: - 输入框组件

/// 文本输入框
struct InputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 20)

            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.5)))
                .foregroundStyle(.white)
                .keyboardType(keyboardType)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            Capsule()
                .fill(.white.opacity(0.15))
        )
    }
}

/// 密码输入框
struct SecureInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 20)

            if isVisible {
                TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.5)))
                    .foregroundStyle(.white)
            } else {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.5)))
                    .foregroundStyle(.white)
            }

            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(
            Capsule()
                .fill(.white.opacity(0.15))
        )
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
