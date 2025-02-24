! Molecular Orbital PACkage (MOPAC)
! Copyright 2021 Virginia Polytechnic Institute and State University
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!    http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.

      subroutine maksym(loc, xparam, xstore)
!-----------------------------------------------
!   M o d u l e s
!-----------------------------------------------
      use molkst_C, only : nvar, ndep, natoms
      use symmetry_C, only : locpar, idepfn, locdep
      use funcon_C, only : pi
      use common_arrays_C, only : na
      use chanel_C, only : iw
!***********************************************************************
      implicit none
!-----------------------------------------------
!   G l o b a l   P a r a m e t e r s
!-----------------------------------------------
    integer, dimension (2, nvar), intent (inout) :: loc
    double precision, dimension (nvar), intent (inout) :: xparam, xstore
!-----------------------------------------------
!   L o c a l   P a r a m e t e r s
!-----------------------------------------------
!-----------------------------------------------
!   L o c a l   V a r i a b l e s
!-----------------------------------------------
      integer :: i, j, loop, locl
      double precision :: twopi, xref
!-----------------------------------------------
!*********************************************************************
!
! MAKSYM CONSTRUCTS THE SYMMETRY DEFINITIONS FOR THE SYSTEM
!        AUTOMATICALLY.  IT RELIES ON IDENTICAL BOND-LENGTHS BEING
!        SYMMETRY RELATED, SIMILARLY FOR ANGLES AND DIHEDRALS.
!
!*********************************************************************
      do i = 2, natoms
        if (na(i) == 0) exit
      end do
      if (i < natoms) then
        write(iw,'(a)')" For AUTOSYM to work, geometry must be in internal coordinates."
        call mopend("For AUTOSYM to work, geometry must be in internal coordinates")
      end if
      twopi = 2.D0*pi
      ndep = 0
      do i = 1, nvar
        if (loc(2,i) == 3) then
!
!  FORCE DIHEDRALS INTO SAME HALF-CIRCLE
!
          j = int(sign(0.5D0,xparam(i))+xparam(i)/twopi)
          xparam(i) = xparam(i) - j*twopi
        end if
        xstore(i) = xparam(i)
      end do
      do loop = 1, nvar
        if (xstore(loop) < (-1.D4)) cycle
        xref = xstore(loop)
        locl = loc(2,loop)
        do i = loop + 1, nvar
          if (abs(xref - xstore(i))>=1.D-3 .or. loc(2,i)/=locl) cycle
          ndep = ndep + 1
          locpar(ndep) = loc(1,loop)
          idepfn(ndep) = locl
          locdep(ndep) = loc(1,i)
          xstore(i) = -1.D5
        end do
!
!   Special, common, dihedral symmetry function
!
        do i = loop + 1, nvar
          if (abs(xref + xstore(i))>=1.D-3 .or. loc(2,i)/=locl) cycle
          ndep = ndep + 1
          locpar(ndep) = loc(1,loop)
          idepfn(ndep) = 14
          locdep(ndep) = loc(1,i)
          xstore(i) = -1.D5
        end do
      end do
      j = 0
      do i = 1, nvar
        if (xstore(i) <= (-1.D4)) cycle
        j = j + 1
        loc(1,j) = loc(1,i)
        loc(2,j) = loc(2,i)
        xparam(j) = xparam(i)
      end do
      nvar = j
      return
      end subroutine maksym
