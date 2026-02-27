//
//  SignupView.swift
//  Clothing Mint
//
//  注册页面，邮箱 + 密码 + 确认密码
//

import SwiftUI

/// 注册页面
struct SignupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AuthViewModel()

    @FocusState private var focusedField: Field?

    enum Field {
        case email, password, confirmPassword
    }

    var body: some View {
        ZStack {
            GradientBackground()

            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)

                    // 顶部标识
                    headerSection

                    // 注册表单
                    formSection

                    // 注册按钮
                    signUpButton

                    // 返回登录
                    backToLoginLink

                    Spacer()
                }
                .padding(.horizontal, 32)
            }
        }
        .navigationBarBackButtonHidden()
        .toast(isPresented: $viewModel.showToast, type: viewModel.toastType, message: viewModel.toastMessage)
        .onTapGesture { focusedField = nil }
    }

    // MARK: - 子视图

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(.white)

            Text("创建账号")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("注册开始管理您的库存")
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
                    placeholder: "密码（至少 6 位）",
                    text: $viewModel.password
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }

                if let error = viewModel.passwordError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.9))
                        .padding(.leading, 4)
                }
            }

            // 确认密码
            VStack(alignment: .leading, spacing: 6) {
                SecureInputField(
                    icon: "lock.rotation",
                    placeholder: "确认密码",
                    text: $viewModel.confirmPassword
                )
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.go)
                .onSubmit { Task { await performSignUp() } }

                if let error = viewModel.confirmPasswordError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.9))
                        .padding(.leading, 4)
                }
            }
        }
    }

    private var signUpButton: some View {
        Button {
            Task { await performSignUp() }
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color.mintPrimary)
                } else {
                    Text("注册")
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
        .disabled(viewModel.isLoading || !viewModel.isSignUpFormValid)
        .opacity(viewModel.isSignUpFormValid ? 1 : 0.6)
    }

    private var backToLoginLink: some View {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Text("已有账号？")
                    .foregroundStyle(.white.opacity(0.7))
                Text("返回登录")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .font(.subheadline)
        }
    }

    // MARK: - 操作

    private func performSignUp() async {
        focusedField = nil
        let success = await viewModel.signUp()
        if success {
            // 注册成功后短暂延时再返回登录页
            try? await Task.sleep(for: .seconds(1.5))
            dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        SignupView()
    }
    .environment(AppState())
}
