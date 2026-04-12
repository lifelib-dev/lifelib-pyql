.. _portfolio:

Portfolio Module
================

.. module:: lifelib_pyql.portfolio

The ``lifelib_pyql.portfolio`` module provides vectorized collections for
bulk construction and management of financial instruments. Rather than
building QuantLib objects one-by-one in Python loops, these classes store
parameters as aligned NumPy arrays and construct individual QuantLib objects
on demand.

.. rubric:: Public API

.. code-block:: python

   from lifelib_pyql.portfolio.time.schedules import Schedules
   from lifelib_pyql.portfolio.instruments.bonds import FixedRateBonds

   # or via the convenience re-export:
   from lifelib_pyql.portfolio.api import Schedules, FixedRateBonds


----


.. _portfolio-schedules:

Schedules
---------

.. module:: lifelib_pyql.portfolio.time.schedules

.. class:: Schedules(effective_dates, termination_dates, tenors, max_size, calendar=TARGET(), convention=ModifiedFollowing, termination_date_convention=ModifiedFollowing, rule=DateGeneration.Backward, end_of_month=False)

   A collection of payment schedules stored as a 2D ``datetime64[D]`` array.

   Bulk-generates QuantLib ``Schedule`` objects from arrays of parameters,
   extracts the resulting dates into a 2D NumPy array, then discards the C++
   objects.  A single C++ ``Schedule`` stack variable is reused for each
   iteration, keeping heap allocation to a minimum.

   **Parameters**

   effective_dates : ndarray of datetime64[D], shape (N,)
       Effective (start) date for each schedule.

   termination_dates : ndarray of datetime64[D], shape (N,)
       Termination (end) date for each schedule.

   tenors : ndarray of int, shape (N,)
       Coupon tenor in months for each schedule (e.g. ``6`` for
       semi-annual, ``12`` for annual).

   max_size : int
       Maximum number of dates per schedule (the 2nd dimension of the
       output ``dates`` array).  A ``ValueError`` is raised during
       construction if any generated schedule has more dates than this.

   calendar : Calendar, optional
       Calendar used for business-day adjustment.
       Default: ``TARGET()``.

   convention : BusinessDayConvention, optional
       Business-day convention applied to intermediate dates.
       Default: ``ModifiedFollowing``.

   termination_date_convention : BusinessDayConvention, optional
       Business-day convention applied to the termination date.
       Default: ``ModifiedFollowing``.

   rule : DateGeneration, optional
       Date-generation rule (``Backward``, ``Forward``, ``Zero``, etc.).
       Default: ``DateGeneration.Backward``.

   end_of_month : bool, optional
       Whether to force dates to fall on the last business day of the
       month when the effective date is the last business day.
       Default: ``False``.

   **Raises**

   ValueError
       If the input arrays have different lengths, or if a generated
       schedule contains more dates than ``max_size``.

   **Properties**

   .. attribute:: dates

      ``ndarray`` of ``datetime64[D]``, shape ``(N, max_size)``.
      Each row holds the dates of one schedule; unused trailing slots are
      filled with ``NaT``.

   .. attribute:: size

      ``ndarray`` of ``int64``, shape ``(N,)``.
      Number of non-``NaT`` dates in each schedule row.

   **Methods**

   .. method:: __len__()

      Return the number of schedules in the collection.

   .. method:: __getitem__(index)

      Index or slice the collection.

      - **int** – Returns a single :class:`lifelib_pyql.time.schedule.Schedule`
        reconstructed from the stored parameters.  Negative indices are
        supported.
      - **slice** – Returns a new :class:`Schedules` containing the selected
        subset.  All parameters (calendar, convention, rule, etc.) are
        preserved.

      :raises IndexError: If an integer index is out of range.
      :raises TypeError: If the index is neither an ``int`` nor a ``slice``.

   .. method:: __repr__()

      Returns ``"<Schedules with N schedules>"``.

   **Example**

   .. code-block:: python

      import numpy as np
      from lifelib_pyql.portfolio.time.schedules import Schedules
      from lifelib_pyql.time.businessdayconvention import ModifiedFollowing
      from lifelib_pyql.time.calendars.target import TARGET
      from lifelib_pyql.time.dategeneration import DateGeneration

      effective_dates = np.array(
          ['2020-01-15', '2020-07-01', '2021-01-01'], dtype='datetime64[D]')
      termination_dates = np.array(
          ['2030-01-15', '2030-07-01', '2031-01-01'], dtype='datetime64[D]')
      tenors = np.array([6, 12, 6])   # months

      scheds = Schedules(
          effective_dates, termination_dates, tenors,
          max_size=25,
          calendar=TARGET(),
          convention=ModifiedFollowing,
          termination_date_convention=ModifiedFollowing,
          rule=DateGeneration.Backward,
          end_of_month=False,
      )

      print(len(scheds))       # 3
      print(scheds.dates.shape)  # (3, 25)
      print(scheds.size)         # number of non-NaT dates per row

      # Get a single QuantLib Schedule
      sched = scheds[0]

      # Get a sub-collection
      sub = scheds[0:2]


----


.. _portfolio-fixedratebonds:

FixedRateBonds
--------------

.. module:: lifelib_pyql.portfolio.instruments.bonds

.. class:: FixedRateBonds(settlement_days, face_amounts, schedules, coupons, accrual_day_counter, payment_convention=Following, redemptions=100.0, issue_dates=None)

   A collection of fixed-rate bonds stored as parallel arrays.

   Stores all bond parameters in aligned NumPy arrays so that large
   portfolios can be constructed and inspected efficiently.  Individual
   :class:`lifelib_pyql.instruments.bonds.FixedRateBond` objects are
   reconstructed on demand when the collection is indexed.

   **Parameters**

   settlement_days : array-like of int, shape (N,)
       Number of settlement days for each bond.

   face_amounts : array-like of float, shape (N,)
       Face (notional) amount for each bond.

   schedules : :class:`~lifelib_pyql.portfolio.time.schedules.Schedules`
       Vectorized schedule collection containing the payment schedules for
       all bonds.  ``len(schedules)`` must equal ``N``.

   coupons : array-like of float
       Coupon rates.

       - Shape ``(N,)`` — one fixed rate per bond.
       - Shape ``(N, M)`` — up to *M* coupon rates per bond;
         unused entries must be ``NaN``.

   accrual_day_counter : DayCounter
       Day-count convention used to accrue interest (shared by all bonds).

   payment_convention : BusinessDayConvention, optional
       Business-day convention for coupon payments (shared by all bonds).
       Default: ``Following``.

   redemptions : float or array-like of float, optional
       Redemption amount(s) at maturity.  A scalar is broadcast to all
       bonds; an array of shape ``(N,)`` sets per-bond values.
       Default: ``100.0``.

   issue_dates : array-like of datetime64[D], shape (N,), or None, optional
       Issue date for each bond.  ``None`` means no issue date is stored
       (QuantLib will use a null ``Date``).
       Default: ``None``.

   **Raises**

   ValueError
       If any of the array arguments have a length that does not match
       ``len(schedules)``, or if ``coupons`` has more than 2 dimensions.

   **Properties**

   .. attribute:: settlement_days

      ``ndarray`` of ``int64``, shape ``(N,)``.
      Settlement days per bond.

   .. attribute:: face_amounts

      ``ndarray`` of ``float64``, shape ``(N,)``.
      Face amounts per bond.

   .. attribute:: schedules

      The :class:`~lifelib_pyql.portfolio.time.schedules.Schedules`
      object passed at construction.

   .. attribute:: coupons

      ``ndarray`` of ``float64``, shape ``(N,)`` or ``(N, M)``.
      Coupon rates as stored (see constructor description).

   .. attribute:: redemptions

      ``ndarray`` of ``float64``, shape ``(N,)``.
      Redemption amounts per bond (always an array, even when a scalar
      was supplied at construction).

   .. attribute:: issue_dates

      ``ndarray`` of ``datetime64[D]``, shape ``(N,)``, or ``None``.
      Issue dates per bond, if provided.

   **Methods**

   .. method:: __len__()

      Return the number of bonds in the collection.

   .. method:: __getitem__(index)

      Index or slice the collection.

      - **int** – Reconstructs and returns a single
        :class:`lifelib_pyql.instruments.bonds.FixedRateBond`.
        Negative indices are supported.
      - **slice** – Returns a new :class:`FixedRateBonds` containing
        the selected subset.  The shared ``accrual_day_counter`` and
        ``payment_convention`` are preserved.

      :raises IndexError: If an integer index is out of range.
      :raises TypeError: If the index is neither an ``int`` nor a ``slice``.

   .. method:: __repr__()

      Returns ``"<FixedRateBonds with N bonds>"``.

   **Example**

   .. code-block:: python

      import numpy as np
      from lifelib_pyql.portfolio.time.schedules import Schedules
      from lifelib_pyql.portfolio.instruments.bonds import FixedRateBonds
      from lifelib_pyql.time.businessdayconvention import (
          ModifiedFollowing, Following)
      from lifelib_pyql.time.calendars.target import TARGET
      from lifelib_pyql.time.dategeneration import DateGeneration
      from lifelib_pyql.time.daycounters.actual_actual import ActualActual

      # --- Build schedules ---
      effective_dates = np.array(
          ['2006-07-10', '2007-01-15', '2008-03-01'], dtype='datetime64[D]')
      termination_dates = np.array(
          ['2016-07-10', '2017-01-15', '2018-03-01'], dtype='datetime64[D]')

      schedules = Schedules(
          effective_dates, termination_dates,
          tenors=np.array([12, 12, 12]),   # annual
          max_size=15,
          calendar=TARGET(),
          convention=ModifiedFollowing,
          termination_date_convention=ModifiedFollowing,
          rule=DateGeneration.Backward,
      )

      # --- Build bond collection ---
      bonds = FixedRateBonds(
          settlement_days=np.array([3, 3, 3]),
          face_amounts=np.array([100.0, 100.0, 100.0]),
          schedules=schedules,
          coupons=np.array([0.05, 0.04, 0.06]),
          accrual_day_counter=ActualActual(ActualActual.ISMA),
          payment_convention=Following,
          redemptions=100.0,
          issue_dates=effective_dates.copy(),
      )

      print(len(bonds))   # 3

      # Retrieve a single QuantLib FixedRateBond
      bond = bonds[0]
      print(bond.start_date, bond.maturity_date)

      # Slice to a sub-portfolio
      sub = bonds[1:3]
      print(len(sub))     # 2

   **Working with 2-D coupons (step-up / step-down bonds)**

   When bonds carry more than one coupon rate over their life, pass a
   2-D array with ``NaN`` padding for bonds that have fewer rates than
   the maximum:

   .. code-block:: python

      cpn_2d = np.array([
          [0.05, 0.04],   # bond 0: two coupons
          [0.03, np.nan], # bond 1: one coupon
          [0.06, 0.05],   # bond 2: two coupons
      ])

      bonds = FixedRateBonds(
          settlement_days=np.array([3, 3, 3]),
          face_amounts=np.array([100.0, 100.0, 100.0]),
          schedules=schedules,
          coupons=cpn_2d,
          accrual_day_counter=ActualActual(ActualActual.ISMA),
      )

      # NaN-padded entries are stripped when constructing individual bonds
      bond1 = bonds[1]   # constructed with coupons=[0.03]


----


.. _portfolio-notes:

Implementation Notes
--------------------

**Memory layout**
  All arrays are stored as contiguous C-order NumPy arrays.  The
  ``datetime64[D]`` dates are stored as ``int64`` (days since Unix epoch)
  internally and cast to ``datetime64[D]`` views for user-facing
  properties.

**Date conversion**
  QuantLib serial numbers use 30 December 1899 as day 0.  Unix epoch
  (1 January 1970) corresponds to serial 25569.  The offset ``val + 25569``
  is applied when converting NumPy ``int64`` values to QuantLib
  ``Date`` objects.

**On-demand reconstruction**
  :class:`Schedules` discards the C++ ``Schedule`` objects after
  extracting dates.  :class:`FixedRateBonds` never constructs the
  underlying C++ ``FixedRateBond`` until an element is accessed by index.
  This keeps memory usage proportional to the number of bonds, not to the
  cost of full QuantLib object initialisation.

**Slicing semantics**
  Slicing returns a new collection sharing the *same* underlying NumPy
  array buffers (NumPy view semantics).  The shared parameters
  (``accrual_day_counter``, ``payment_convention``, ``calendar``,
  ``convention``, ``rule``, ``end_of_month``) are shallow-copied by
  reference.

**Thread safety**
  These classes make no use of global state.  Concurrent read-only access
  (e.g. parallel pricing of individual bonds) is safe.  Mutating the
  underlying arrays directly is not supported and will lead to undefined
  behaviour.
