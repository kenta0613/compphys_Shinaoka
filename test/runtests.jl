using Test
using compphys_Shinaoka

@testset "compphys_Shinaoka" begin

    @testset "init_spins" begin
        spins = init_spins(4)
        @test size(spins) == (4, 4)
        @test eltype(spins) == Int8
        @test all(x -> x == 1 || x == -1, spins)
        @test init_spins(4, seed=42) == init_spins(4, seed=42)
    end

    @testset "magnetization" begin
        model_up   = IsingModel(ones(Int8, 4, 4),  0.5)
        model_down = IsingModel(fill(Int8(-1), 4, 4), 0.5)
        @test magnetization(model_up)   ≈  1.0
        @test magnetization(model_down) ≈ -1.0
    end

    @testset "energy" begin
        # 全スピンアップ: E = -J * 2 * L^2 = -32.0
        model_up   = IsingModel(ones(Int8, 4, 4),     0.5)
        model_down = IsingModel(fill(Int8(-1), 4, 4), 0.5)
        @test energy(model_up)   ≈ -32.0
        @test energy(model_down) ≈ -32.0
    end

    @testset "energy consistency with calc_dE" begin
        # calc_dE の予測値と energy の差分が一致するか
        model        = IsingModel(4, 0.5, seed=42)
        i, j         = 2, 3
        dE_predicted = compphys_Shinaoka.calc_dE(model, i, j)
        E_before     = energy(model)
        model.spins[i, j] *= -1
        E_after      = energy(model)
        @test E_after - E_before ≈ dE_predicted
    end

    @testset "run_simulation!" begin
        # 実行してもクラッシュしないか、型が変わらないか
        model = IsingModel(4, 0.5, seed=42)
        run_simulation!(model, 10)
        @test size(model.spins) == (4, 4)
        @test eltype(model.spins) == Int8
        @test all(x -> x == 1 || x == -1, model.spins)
    end

end
