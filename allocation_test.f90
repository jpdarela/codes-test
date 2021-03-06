module allocation_test
    use ISO_FORTRAN_ENV, only: REAL32, REAL64, REAL128
    use constants
    implicit none

    real(REAL64) :: H = 108.91909828977032
    real(REAL64) :: L = 1.2279169651518438
    real(REAL64) :: R = 29.790591253578555
    real(REAL64) :: S = 0.88026193814051623

    ! real(REAL64) :: H = 108.91909828977032 !HEARTWOOD - SOMENTE PARA TESTES (Valores: Cod. Philipe)
    ! real(REAL64) :: L = 1.2279169651518438 !LEAF BIOMASS - SOMENTE PARA TESTES (Valores: Cod. Philipe)
    ! real(REAL64) :: S = 29.790591253578555 !SAPWOOD - SOMENTE PARA TESTES (Valores: Cod. Philipe)
    ! real(REAL64) :: R = 0.88026193814051623 !ROOT BIOMASS - SOMENTE PARA TESTES (Valores: Cod. Philipe)
    
    contains

    !==============================!
	!= Subrotines
	!==============================!
    ! Just to test comparisons with "tol" value
    ! It can be deleted later
    ! subroutine show_consts()
    !     implicit none
    !     real(REAL128) :: x = 0.0000001
        
    !     print*, 'show_consts()'
    !     print '(F11.9)', tol

    !     if(x .eq. tol) then
    !         print*, 'eq'
    !     elseif(x .gt. tol) then
    !         print*, 'gt'
    !     else
    !         print*, 'lt'
    !     end if

    ! end subroutine show_consts

    ! Use the bisection method to solve the leaf mass increment
    subroutine leaf_carbon(delta_leaf)
        real(REAL64) :: delta_leaf

        delta_leaf = bisection_method(0.0, 10.0)
        
        return
    end subroutine leaf_carbon

	! Once we have the leaf mass increment we can cant get 
    ! root mass increment based on the LTOR constant
    subroutine root_carbon(delta_leaf, delta_root)
        real(REAL64) :: delta_leaf
        real(REAL64) :: delta_root
        
        delta_root = (delta_leaf + L) / ltor - R
        
        return
    end subroutine root_carbon

    ! Finally using the cmass_increment mass conservation we can calculate sapwood increment
    subroutine sapwood_carbon(delta_leaf, delta_root, delta_sapwood)
        real(REAL64) :: delta_leaf
        real(REAL64) :: delta_root
        real(REAL64) :: delta_sapwood
        
        delta_sapwood = bminc - delta_leaf - delta_root
        
        return
    end subroutine sapwood_carbon


	!==============================!
	!= Functions
	!==============================!
    function bisection_method(a, b) result(midpoint)
        implicit none
        real(REAL32) :: a, b
        real(REAL64) :: aux_a, aux_b
        real(REAL64) :: midpoint
        
        aux_a = a
        aux_b = b

        if((f(aux_a) * f(aux_b)) .gt. 0) then
            midpoint = -2.0
            return
        endif
        
        do while((aux_b - aux_a) / 2.0 .gt. tol)
            midpoint = (aux_a + aux_b) / 2
            
            if(f(midpoint) .eq. 0.0) then
                exit            
            elseif(f(aux_a) * f(midpoint) .lt. 0) then
                aux_b = midpoint
            else
                aux_a = midpoint
            endif
        end do
    end function bisection_method

    function f(x) result(searched_x)
        implicit none
        real(REAL64) :: x
        real(REAL64) :: searched_x
        
        searched_x = & 
            calc_tau1() * &
            (sapwood() - x - x / ltor + H) - &
            ( &
                (sapwood() - x - x / ltor) / &
                (L + x) * calc_tau3() &
            ) ** calc_tau2()
    end function f

    function calc_tau1() result(tau1)
        implicit none
        real(REAL64) :: tau1
        
        tau1 = k_allom2 ** (2.0 / k_allom3) * 4.0 / 3.14159 / dw
    end function calc_tau1

    function calc_tau2() result(tau2)
        implicit none
        real(REAL64) :: tau2 
        
        tau2 = 1.0 + 2.0 / k_allom3
    end function calc_tau2

    function calc_tau3() result(tau3)
        implicit none
        real(REAL64) :: tau3
        
        tau3 = klatosa / dw / spec_leaf
    end function calc_tau3

    function sapwood () result (SS)
         implicit none
         real(REAL64) :: SS
        
         SS = S + bminc - L / ltor + R
    end function sapwood

    function total_carbon_sap (delta_sapwood, H, S) result (cstem)
        implicit none 
        real(REAL64) :: delta_sapwood
        real(REAL64) :: H
        real(REAL64) :: S
        real(REAL64) :: new_stem
        real(REAL64) :: new_sw
        real(REAL64) :: cstem

        new_stem = delta_sapwood
        new_sw = H + S

        cstem = new_sw + new_stem

    end function total_carbon_sap

end module allocation_test
